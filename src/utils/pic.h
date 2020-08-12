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

#ifndef PIC_H
#define PIC_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QVariantList>
#include <QJsonDocument>
#include <QJsonObject>

#ifndef STATIC_MAUIKIT
#include "../pix_version.h"
#endif

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <MauiKit/utils.h>
#include <MauiKit/fmh.h>
#else
#include "utils.h"
#include "fmh.h"
#endif


namespace PIX
{
//Q_NAMESPACE

enum SearchT
{
    LIKE,
    SIMILAR
};

typedef QMap<PIX::SearchT,QString> SEARCH;

inline static const SEARCH SearchTMap
{
    { PIX::SearchT::LIKE, "like" },
    { PIX::SearchT::SIMILAR, "similar" }
};

enum class W : uint_fast8_t
{
    ALL,
    NONE,
    LIKE,
    TAG,
    SIMILAR,
    UNKNOWN,
    DONE,
    DESC,
    ASC
};

inline static const QMap<W,QString> SLANG =
{
    {W::ALL, "ALL"},
    {W::NONE, "NONE"},
    {W::LIKE, "LIKE"},
    {W::SIMILAR, "SIMILAR"},
    {W::UNKNOWN, "UNKNOWN"},
    {W::DONE, "DONE"},
    {W::DESC, "DESC"},
    {W::ASC,"ASC"},
    {W::TAG,"TAG"}
};

enum class TABLE : uint8_t
{
    SOURCES,
    IMAGES,
    TAGS,
    ALBUMS,
    IMAGES_TAGS,
    IMAGES_ALBUMS,
    ALBUMS_TAGS,
    IMAGES_NOTES,
    ALL,
    NONE
};

inline static const QMap<TABLE,QString> TABLEMAP =
{
    {TABLE::ALBUMS,"albums"},
    {TABLE::SOURCES,"sources"},
    {TABLE::IMAGES,"images"},
    {TABLE::IMAGES_TAGS,"images_tags"},
    {TABLE::IMAGES_ALBUMS,"images_albums"},
    {TABLE::ALBUMS_TAGS,"albums_tags"},
    {TABLE::IMAGES_NOTES,"images_notes"},
    {TABLE::TAGS,"tags"}
};

inline const static auto SettingPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/pix/");
inline const static auto CollectionDBPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/pix/");
inline const static auto CachePath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)+"/pix/");
inline const static auto NotifyDir = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation));

inline const static QString appName = QStringLiteral("pix");
inline const static QString displayName = QStringLiteral("Pix");
inline const static QString version = PIX_VERSION_STRING;
inline const static QString description = QStringLiteral("Image Viewer");
inline const static QString orgName = QStringLiteral("Maui");
inline const static QString orgDomain = QStringLiteral("org.maui.pix");

inline const static QString DBName = "collection.db";

inline const static QStringList MoodColors = {"#F0FF01","#01FF5B","#3DAEFD","#B401FF","#E91E63"};

inline static const QString ucfirst(const QString &str)/*uppercase first letter*/
{
    if (str.isEmpty()) return "";

    QStringList tokens;
    QStringList result;
    QString output;

    if(str.contains(" "))
    {
        tokens = str.split(" ");

        for(auto str : tokens)
        {
            str = str.toLower();
            str[0] = str[0].toUpper();
            result<<str;
        }

        output = result.join(" ");
    }else output = str;

    return output.simplified();
}

inline static const QString getQuery(const QString &key)
{
    QString json;
    QFile file;
    file.setFileName(":/db/Query.js");
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    json = file.readAll();
    file.close();

    qDebug()<< json;
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(json.toUtf8(), &jsonParseError);
    qDebug()<< "trying to get query from key1"<< key;

    if (jsonParseError.error != QJsonParseError::NoError)
        return "";
    qDebug()<< "trying to get query from key2"<< key;

    if (!jsonResponse.isObject())
        return "";

    qDebug()<< "trying to get query from key3"<< key;
    QJsonObject mainJsonObject(jsonResponse.object());
    auto data = mainJsonObject.toVariantMap();
    auto itemMap = data.value("Query").toMap();

    if(itemMap.isEmpty()) return "";

    return itemMap.value(key).toString();
}

inline static const QStringList getSourcePaths()
{
    static const QStringList defaultSources  = {FMH::PicturesPath, FMH::DownloadsPath};
    const auto sources = UTIL::loadSettings("Sources", "Settings", defaultSources).toStringList();
    qDebug()<< "SOURCES" << sources;
    return sources;
}

inline static void saveSourcePath(QStringList const& paths)
{
    auto sources = PIX::getSourcePaths();

    sources << paths;
    sources.removeDuplicates();

    qDebug()<< "Saving new sources" << sources;
    UTIL::saveSettings("Sources", sources, "Settings");
}

inline static void removeSourcePath(const QString &path)
{
    auto sources = PIX::getSourcePaths();
    sources.removeOne(path);

    UTIL::saveSettings("Sources", sources, "Settings");
}

}

#endif // PIC_H
