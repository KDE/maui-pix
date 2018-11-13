/***
Pix  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/
#ifndef FILELOADER_H
#define FILELOADER_H

#include <QThread>
#include <QObject>
#include <QDirIterator>
#include <QFileInfo>
#include "dbactions.h"

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <MauiKit/fmh.h>
#else
#include "fmh.h"
#endif

class FileLoader : public DBActions
{
    Q_OBJECT

public:
    FileLoader() : DBActions()
    {
        qRegisterMetaType<PIX::DB>("PIX::DB");
        qRegisterMetaType<PIX::TABLE>("PIX::TABLE");
        qRegisterMetaType<QMap<PIX::TABLE, bool>>("QMap<PIX::TABLE,bool>");
        this->moveToThread(&t);
        t.start();
    }

    ~FileLoader()
    {
        this->go = false;
        this->t.quit();
        this->t.wait();
    }

    void requestPath(QStringList paths)
    {
        qDebug()<<"FROM file loader"<< paths;

        this->go = true;
        QMetaObject::invokeMethod(this, "getPics", Q_ARG(QStringList, paths));
    }

    void nextTrack()
    {
        this->wait = !this->wait;
    }

public slots:

    void getPics(QStringList paths)
    {
        qDebug()<<"GETTING IMAGES";

        QStringList urls;

        for(auto path : paths)
            if (QFileInfo(path).isDir())
            {
                QDirIterator it(path, FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], QDir::Files, QDirIterator::Subdirectories);

                while (it.hasNext())
                    urls << it.next();

            }else if (QFileInfo(path).isFile())
                urls << path;

        int newPics = 0;

        if(urls.size() > 0)
        {
            for(auto url : urls)
            {
                if(go)
                {
                    if(this->addPic(url))
                        newPics++;
                }else break;
            }
            emit collectionSize(newPics);
        }

        this->t.msleep(100);

        emit this->finished(newPics);
        this->go = false;
    }

signals:
    void trackReady(PIX::DB track);
    void finished(int size);
    void collectionSize(int size);

private:
    QThread t;
    bool go = false;
    bool wait = true;
    QStringList queue;
};


#endif // FILELOADER_H
