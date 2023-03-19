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

#include <MauiKit/Core/fmh.h>
#include <MauiKit/Core/utils.h>

#include <MauiKit/FileBrowsing/tagging.h>
#include <MauiKit/FileBrowsing/fmstatic.h>

#include "models/gallery/gallery.h"

Pix *Pix::m_instance = nullptr;

Pix::Pix(QObject *parent) : QObject(parent)
  ,m_allImagesModel(nullptr)
{
    connect(qApp, &QCoreApplication::aboutToQuit, []()
    {
        delete m_instance;
        m_instance = nullptr;
    });
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
    if(!m_allImagesModel)
    {
        m_allImagesModel = new Gallery(this);
        m_allImagesModel->setUrls(QUrl::fromStringList(sources()));
        m_allImagesModel->setRecursive(true);
        m_allImagesModel->componentComplete(); //call this to actually get the data
        connect(this, &Pix::sourcesChanged, [this]()
        {
            m_allImagesModel->setUrls(QUrl::fromStringList(sources()));
        });
    }
    return m_allImagesModel;
}

const QStringList Pix::getSourcePaths()
{
    static const auto defaultSources = QStringList{FMStatic::PicturesPath, FMStatic::DownloadsPath} << cameraPath().toString() + screenshotsPath().toString();
    const auto sources = UTIL::loadSettings("Sources", "Settings", defaultSources).toStringList();
    qDebug() << "SOURCES" << sources;
    return sources;
}

void Pix::saveSourcePath(const QStringList &paths)
{
    auto sources = getSourcePaths();

    sources << paths;
    sources.removeDuplicates();

    UTIL::saveSettings("Sources", sources, "Settings");
}

void Pix::removeSourcePath(const QString &path)
{
    auto sources = getSourcePaths();
    sources.removeOne(path);

    UTIL::saveSettings("Sources", sources, "Settings");
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
    emit this->viewPics(QUrl::toStringList(pics));
}

void Pix::showInFolder(const QStringList &urls)
{
    for (const auto &url : urls)
        QDesktopServices::openUrl(FMStatic::fileDir(url));
}

void Pix::addSources(const QStringList &paths)
{
    saveSourcePath(paths);
    emit sourcesChanged();
}

void Pix::removeSources(const QString &path)
{
    removeSourcePath(path);
    emit sourcesChanged();
}
