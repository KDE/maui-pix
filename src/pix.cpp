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

Pix::Pix(QObject *parent) : DBActions(parent)
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
            emit refreshViews({{PIX::TABLEMAP[TABLE::ALBUMS], true},
                               {PIX::TABLEMAP[TABLE::TAGS], true},
                               {PIX::TABLEMAP[TABLE::IMAGES], true}});
    });

}

Pix::~Pix()
{
    delete this->fileLoader;
}

bool Pix::isAndroid()
{
    return PIX::isAndroid();
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
            {PIX::KEYMAP[PIX::KEY::URL], url},
            {PIX::KEYMAP[PIX::KEY::TITLE], title},
            {PIX::KEYMAP[PIX::KEY::FAV], "0"},
            {PIX::KEYMAP[PIX::KEY::RATE], "0"},
            {PIX::KEYMAP[PIX::KEY::COLOR], ""},
            {PIX::KEYMAP[PIX::KEY::SOURCES_URL], sourceUrl},
            {PIX::KEYMAP[PIX::KEY::PIC_DATE], info.created().toString()},
            {PIX::KEYMAP[PIX::KEY::FORMAT], format}
        };

        data << picMap;
    }

    emit viewPics(data);
}

void Pix::refreshCollection()
{
    this->populateDB({PIX::PicturesPath, PIX::DownloadsPath, PIX::DocumentsPath});
}

bool Pix::run(const QString &query)
{
    return this->execQuery(query);
}

void Pix::populateDB(const QStringList &paths)
{
    qDebug() << "Function Name: " << Q_FUNC_INFO
             << "new path for database action: " << paths;
    QStringList newPaths;

    for(auto path : paths)
    {
        if(path.startsWith("file://"))

            newPaths << path.replace("file://", "");
        else
            newPaths<<path;

        qDebug()<<"paths to scan"<<newPaths;
    }

    fileLoader->requestPath(newPaths);
}

void Pix::saveSettings(const QString &key, const QVariant &value, const QString &group)
{
    PIX::saveSettings(key, value, group);
}

QVariant Pix::loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
{
    return PIX::loadSettings(key, group, defaultValue);
}

bool Pix::removeFile(const QString &url)
{
    QFile file(url);
    if(!file.exists()) return false;

    if(file.remove())
        return removePic(url);

    return false;
}

void Pix::showInFolder(const QString &url)
{
    QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(url).dir().absolutePath()));
}




