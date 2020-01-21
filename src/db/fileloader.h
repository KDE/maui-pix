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
#include <QThread>

#include "dbactions.h"

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <MauiKit/fmh.h>
#else
#include "fmh.h"
#endif

class MThread : public QThread
{

};

class FileLoader : public QObject
{
    Q_OBJECT

public:
    FileLoader() : QObject()
    {
        //        qRegisterMetaType<PIX::TABLE>("PIX::TABLE");
        //        qRegisterMetaType<QMap<PIX::TABLE, bool>>("QMap<PIX::TABLE,bool>");

        this->moveToThread(&t);
        connect(this, &FileLoader::start, this, &FileLoader::getPics);
        this->t.start();
    }

    void requestPath(const QList<QUrl> &urls)
    {
        qDebug()<<"FROM file loader"<< urls;
        this->go = true;
        emit this->start(urls);
    }

private slots:
    void getPics(QList<QUrl> paths)
    {
        qDebug()<<"GETTING IMAGES";

        QList<QUrl> urls;

        for(const auto &path : paths)
        {
            if (QFileInfo(path.toLocalFile()).isDir() && path.isLocalFile())
            {
                QDirIterator it(path.toLocalFile(), FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], QDir::Files, QDirIterator::Subdirectories);

                while (it.hasNext())
                    urls << QUrl::fromLocalFile(it.next());

            }else if (QFileInfo(path.toLocalFile()).isFile())
                urls << path;
        }

        uint newPics = 0;

        if(urls.size() > 0)
        {
            const auto db_ = DBActions::getInstance();
            for(const auto &url : urls)
            {
                if(go)
                {
                    if(db_->addPic(url.toString()))
                        newPics++;
                }else break;
            }
            emit this->collectionSize(newPics);
        }

        emit this->finished(newPics);
        this->go = false;
        t.quit();
    }

signals:
    void finished(uint size);
    void collectionSize(uint size);
    void start(QList<QUrl> urls);

private:
    QThread t;
    bool go = false;
};


#endif // FILELOADER_H
