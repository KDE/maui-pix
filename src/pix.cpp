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

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include "kde/notify.h"
#include "kde/kdeconnect.h"
#include "kde/kde.h"
#endif

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

QVariantList Pix::getList(const QStringList &urls)
{
    QVariantList mapList;

    for(auto url : urls)
    {
        auto queryTxt = QString("SELECT * FROM %1 WHERE %2 = \"%3\"").arg(TABLEMAP[TABLE::IMAGES],
                KEYMAP[KEY::URL], url);

        mapList << this->get(queryTxt);
    }

    return mapList;
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

QString Pix::pixColor()
{
    return "#03A9F4";
}

void Pix::saveSettings(const QString &key, const QVariant &value, const QString &group)
{
    PIX::saveSettings(key, value, group);

}

QVariant Pix::loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
{
    return PIX::loadSettings(key, group, defaultValue);
}

int Pix::screenGeometry(QString &side)
{
    side = side.toLower();
    auto geo = QApplication::desktop()->screenGeometry();

    if(side == "width")
        return geo.width();
    else if(side == "height")
        return geo.height();
    else return 0;
}

int Pix::cursorPos(QString &axis)
{
    axis = axis.toLower();
    auto pos = QCursor::pos();
    if(axis == "x")
        return pos.x();
    else if(axis == "y")
        return pos.y();
    else return 0;
}

QString Pix::homeDir()
{
    return PIX::PicturesPath;
}

QVariantList Pix::getDirs(const QString &pathUrl)
{
    auto path = pathUrl;
    if(path.startsWith("file://"))
        path.replace("file://", "");
    qDebug()<<"DIRECTRORY"<<path;
    QVariantList paths;

    if (QFileInfo(path).isDir())
    {
        QDirIterator it(path, QDir::Dirs, QDirIterator::NoIteratorFlags);
        while (it.hasNext())
        {
            auto url = it.next();
            auto name = QDir(url).dirName();
            qDebug()<<name<<url;
            QVariantMap map = { {"url", url }, {"name", name} };
            paths << map;
        }
    }

    return paths;
}

QVariantMap Pix::getParentDir(const QString &path)
{
    auto dir = QDir(path);
    dir.cdUp();
    auto dirPath = dir.absolutePath();

    if(dir.isReadable() && !dir.isRoot() && dir.exists())
        return {{"url", dirPath}, {"name", dir.dirName()}};
    else
        return {{"url", path}, {"name", QFileInfo(path).dir().dirName()}};

}

QVariantList Pix::openWith(const QString &url)
{
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    return KDE::mimeApps(url);
#elif defined (Q_OS_ANDROID)
    return QVariantList();
#endif
}

void Pix::runApplication(const QString &exec, const QString &url)
{
    qDebug()<<"RUN:"<<exec<<url;
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    return KDE::openWithApp(exec, url);
#endif
}

QVariantList Pix::getDevices()
{
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    return  KdeConnect::getDevices();
#endif
}

bool Pix::sendToDevice(const QString &name, const QString &id, const QString &url)
{
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    return KdeConnect::sendToDevice(name, id, url);
#endif
}

void Pix::attachToEmail(const QString &url)
{
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    KDE::attachEmail(url);
#endif
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




