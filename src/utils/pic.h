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

namespace PIX
{
Q_NAMESPACE

enum SearchT
{
    LIKE,
    SIMILAR
};

typedef QMap<PIX::SearchT,QString> SEARCH;

static const SEARCH SearchTMap
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

static const QMap<W,QString> SLANG =
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

static const QMap<TABLE,QString> TABLEMAP =
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

//enum KEY : uint8_t
//{
//    URL,
//    SOURCES_URL,
//    TITLE,
//    ALBUM,
//    RATE,
//    FAV,
//    COLOR,
//    NOTE,
//    ADD_DATE,
//    PIC_DATE,
//    PLACE,
//    FORMAT,
//    TAG,
//    SIZE,
//    NONE
//}; Q_ENUM_NS(KEY)

//typedef QMap<PIX::KEY, QString> DB;
//typedef QList<DB> DB_LIST;

//static const DB KEYMAP =
//{
//    {KEY::URL, "url"},
//    {KEY::SOURCES_URL, "sources_url"},
//    {KEY::RATE, "rate"},
//    {KEY::TITLE, "title"},
//    {KEY::ALBUM, "album"},
//    {KEY::FAV, "fav"},
//    {KEY::COLOR, "color"},
//    {KEY::NOTE, "note"},
//    {KEY::PIC_DATE, "picDate"},
//    {KEY::PLACE, "place"},
//    {KEY::FORMAT, "format"},
//    {KEY::ADD_DATE, "addDate"},
//    {KEY::SIZE, "size"},
//    {KEY::TAG, "tag"}
//};

//static const QMap<QString, PIX::KEY> MAPKEY =
//{
//    {PIX::KEYMAP[PIX::KEY::URL], PIX::KEY::URL},
//    {PIX::KEYMAP[PIX::SOURCES_URL], PIX::SOURCES_URL},
//    {PIX::KEYMAP[PIX::RATE], PIX::RATE},
//    {PIX::KEYMAP[PIX::TITLE], PIX::TITLE},
//    {PIX::KEYMAP[PIX::ALBUM], PIX::ALBUM},
//    {PIX::KEYMAP[PIX::FAV], PIX::FAV},
//    {PIX::KEYMAP[PIX::COLOR], PIX::COLOR},
//    {PIX::KEYMAP[PIX::NOTE], PIX::NOTE},
//    {PIX::KEYMAP[PIX::PIC_DATE], PIX::PIC_DATE},
//    {PIX::KEYMAP[PIX::PLACE], PIX::PLACE},
//    {PIX::KEYMAP[PIX::FORMAT], PIX::FORMAT},
//    {PIX::KEYMAP[PIX::ADD_DATE], PIX::ADD_DATE},
//    {PIX::KEYMAP[PIX::SIZE], PIX::SIZE},
//    {PIX::KEYMAP[PIX::TAG], PIX::TAG}
//};


const QString SettingPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/pix/";
const QString CollectionDBPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/pix/";
const QString CachePath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)+"/pix/";
const QString NotifyDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
const QString App = "Pix";
const QString version = "1.0";
const QString comment = "Gallery image viewer";
const QString DBName = "collection.db";

const QStringList MoodColors = {"#F0FF01","#01FF5B","#3DAEFD","#B401FF","#E91E63"};

inline QString ucfirst(const QString &str)/*uppercase first letter*/
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

inline QString getQuery(const QString &key)
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

}




#endif // PIC_H
