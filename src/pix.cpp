// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

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
#include <QDesktopServices>
#include <QDebug>
#include <QCoreApplication>
#include <QGuiApplication>
#include <QSettings>
#include <QProcess>
#include <MauiKit4/Core/fmh.h>

#include <MauiKit4/FileBrowsing/tagging.h>
#include <MauiKit4/FileBrowsing/fmstatic.h>

#include "models/gallery/gallery.h"

Q_GLOBAL_STATIC(Pix, pixInstance)

Pix::Pix(QObject *parent) : QObject(parent)
    , m_allImagesModel(nullptr)
{
}

QUrl Pix::cameraPath()
{
    const static auto paths = QStringList{FMStatic::HomePath + "/DCIM/Camera", FMStatic::HomePath + "/Camera", FMStatic::PicturesPath+"/Camera", FMStatic::PicturesPath+"/camera"};

    for (const auto &path : paths)
    {
        if (FMH::fileExists(path))
            return QUrl(path);
    }

    return QUrl();
}

QUrl Pix::screenshotsPath()
{
    const static auto paths = QStringList{FMStatic::HomePath + "/DCIM/Screenshots", FMStatic::HomePath + "/Screenshots",FMStatic::PicturesPath+"/screenshots" , FMStatic::PicturesPath+"/Screenshots"};

    for (const auto &path : paths) {
        if (FMH::fileExists(path))
            return QUrl(path);
    }

    return QUrl();
}

Gallery *Pix::allImagesModel()
{
    qDebug() << "REQUEST ALL IMAGES MODEL";
    if(!m_allImagesModel)
    {
        qDebug() << "REQUEST ALL IMAGES MODEL &CREATING";

        m_allImagesModel = new Gallery(this);
        m_allImagesModel->setUrls(QUrl::fromStringList(sources()));
        m_allImagesModel->setRecursive(true);
        m_allImagesModel->componentComplete(); //call this to actually get the data
        connect(this, &Pix::sourcesChanged, [this]()
                {
                    m_allImagesModel->setUrls(QUrl::fromStringList(sources()));
                });
    }

    qDebug() << "REQUEST ALL IMAGES MODEL & EXISTING ONE";

    return m_allImagesModel;
}

Pix *Pix::instance()
{
    return pixInstance();
}

const QStringList Pix::getSourcePaths()
{
    static const auto defaultSources = QStringList{FMStatic::PicturesPath, FMStatic::DownloadsPath} << cameraPath().toString() + screenshotsPath().toString();
    QSettings settings;
    settings.beginGroup("Settings");
    const auto sources = settings.value("Sources", defaultSources).toStringList();
    settings.endGroup();
    qDebug() << "SOURCES" << sources;
    return sources;
}

void Pix::saveSourcePath(const QStringList &paths)
{
    auto sources = getSourcePaths();

    sources << paths;
    sources.removeDuplicates();

    QSettings settings;
    settings.beginGroup("Settings");
    settings.setValue("Sources", sources);
    settings.endGroup();
}

void Pix::removeSourcePath(const QString &path)
{
    auto sources = getSourcePaths();
    sources.removeOne(path);

    QSettings settings;
    settings.beginGroup("Settings");
    settings.setValue("Sources", sources);
    settings.endGroup();
}

QVariantList Pix::sourcesModel() const
{
    QVariantList res;
    const auto sources = getSourcePaths();
    return std::accumulate(sources.constBegin(), sources.constEnd(), res, [](QVariantList &res, const QString &url) {
        res << FMStatic::getFileInfo(url);
        return res;
    });
}

QStringList Pix::sources() const
{
    return getSourcePaths();
}

void Pix::openPics(const QList<QUrl> &pics)
{
    Q_EMIT this->viewPics(QUrl::toStringList(pics));
}

void Pix::showInFolder(const QStringList &urls)
{
    for (const auto &url : urls)
        QDesktopServices::openUrl(FMStatic::fileDir(url));
}

void Pix::createNote(const QString &text)
{
    QString program = "buho";
    QStringList arguments;
    arguments << "-n" << "-c" << text.toUtf8();

    QProcess *myProcess = new QProcess();
    myProcess->startDetached(program, arguments);
    // myProcess->deleteLater();
}

void Pix::addSources(const QStringList &paths)
{
    saveSourcePath(paths);
    Q_EMIT sourcesChanged();
}

void Pix::removeSources(const QString &path)
{
    removeSourcePath(path);
    Q_EMIT sourcesChanged();
}

FileWatcher::FileWatcher(QObject *parent) : QObject(parent)
    ,m_watcher(new QFileSystemWatcher(this))
{
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &FileWatcher::onFileChanged);
}

QString FileWatcher::url() const
{
    return m_url;
}

void FileWatcher::setUrl(const QString &newUrl)
{
    if (m_url == newUrl)
        return;
    m_url = newUrl;
    qDebug()  << "new file to watch" << m_url;
    m_watcher->removePaths(m_watcher->files());
    m_watcher->addPath(QUrl(m_url).toLocalFile());

    Q_EMIT urlChanged();
}

void FileWatcher::onFileChanged(const QString &url)
{
    if(FMH::fileExists(QUrl::fromLocalFile(url)))
    {
        qDebug() << "The watched file was removed" << url;

        Q_EMIT fileModified();
    }else
    {
        qDebug() << "The watched file was changed" << url;

        m_watcher->removePaths(m_watcher->files());
        setUrl({});
        Q_EMIT fileDeleted();
    }
}
