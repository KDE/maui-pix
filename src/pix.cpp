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

#include "pix.h"
#include "db/fileloader.h"
#include <QFileSystemWatcher>
#include <QTimer>
#include <QApplication>
#include <QDesktopWidget>
#include <QDirIterator>
#include <QtQml>
#include <QPalette>
#include <QWidget>
#include <QColor>
#include <QDesktopServices>

using namespace PIX;

Pix::Pix(QObject *parent) : QObject(parent)
{
    qDebug() << "Getting settings info from: " << PIX::SettingPath;

    //    if(!PIX::fileExists(notifyDir+"/Pix.notifyrc"))
    //    {
    //        qDebug()<<"The Knotify file does not exists, going to create it";
    //        QFile knotify(":Data/data/Pix.notifyrc");

    //        if(knotify.copy(notifyDir+"/Pix.notifyrc"))
    //            qDebug()<<"the knotify file got copied";
    //    }


    this->fileLoader = new FileLoader;
    connect(this->fileLoader, &FileLoader::finished,[this](int size)
    {
        Q_UNUSED(size);
        emit refreshViews({
                              {PIX::TABLEMAP[TABLE::ALBUMS], true},
                              {PIX::TABLEMAP[TABLE::TAGS], true},
                              {PIX::TABLEMAP[TABLE::IMAGES], true}
                          });
    });
}

Pix::~Pix()
{
    delete this->fileLoader;
}

void Pix::openPics(const QStringList &pics)
{
    QVariantList data;

    for(auto url : pics)
    {
        QFileInfo info(url);
        auto title = info.baseName();
        auto format = info.suffix();
        auto sourceUrl = info.dir().path();

        QVariantMap picMap =
        {
            {FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], title},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::FAV], "0"},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::RATE], "0"},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR], ""},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::SOURCE], sourceUrl},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::DATE], info.birthTime().toString()},
            {FMH::MODEL_NAME[FMH::MODEL_KEY::FORMAT], format}
        };

        data << picMap;
    }

    emit viewPics(data);
}

void Pix::refreshCollection()
{
    this->populateDB({FMH::PicturesPath, FMH::DownloadsPath, FMH::DocumentsPath, FMH::CloudCachePath});
}

void Pix::populateDB(const QStringList &paths)
{
    qDebug() << "Function Name: " << Q_FUNC_INFO
             << "new path for database action: " << paths;
    QStringList newPaths;

    for(auto path : paths)
        if(path.startsWith("file://"))
            newPaths << path.replace("file://", "");
        else
            newPaths << path;

    qDebug()<<"paths to scan"<<newPaths;

    fileLoader->requestPath(newPaths);
}

void Pix::showInFolder(const QStringList &urls)
{
    for(auto url : urls)
        QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(url).dir().absolutePath()));
}

void Pix::addSources(const QStringList &paths)
{
    this->populateDB(paths);
}
