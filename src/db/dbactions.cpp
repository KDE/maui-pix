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

#include "dbactions.h"
#include "db.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "tagging.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/tagging.h>
#endif


DBActions::DBActions(QObject *parent) : QObject(parent)
{
    qDebug() << "Getting collectionDB info from: " << PIX::CollectionDBPath;

    qDebug()<< "Starting DBActions";

    this->db = DB::getInstance();
    this->tag = Tagging::getInstance(PIX::App, PIX::version, "org.kde.pix", PIX::comment);
}

DBActions::~DBActions() {}


bool DBActions::execQuery(const QString &queryTxt)
{
    auto query = this->db->getQuery(queryTxt);
    return query.exec();
}

bool DBActions::insertPic(const PIX::DB &img)
{
    auto url = img[PIX::KEY::URL];
    auto title = img[PIX::KEY::TITLE];
    auto rate = img[PIX::KEY::RATE];
    auto fav = img[PIX::KEY::FAV];
    auto color = img[PIX::KEY::COLOR];
    auto addDate = img[PIX::KEY::ADD_DATE];
    auto sourceUrl = img[PIX::KEY::SOURCES_URL];
    auto picDate = img[PIX::KEY::PIC_DATE];
    auto place = img[PIX::KEY::PLACE];
    auto format = img[PIX::KEY::FORMAT];

    qDebug()<< "writting to db: "<<title<<url;
    /* first needs to insert album and artist*/
    QVariantMap sourceMap {{PIX::KEYMAP[PIX::KEY::URL],sourceUrl}};
    this->db->insert(PIX::TABLEMAP[PIX::TABLE::SOURCES], sourceMap);


    QVariantMap imgMap {{PIX::KEYMAP[PIX::KEY::URL], url},
                        {PIX::KEYMAP[PIX::KEY::SOURCES_URL], sourceUrl},
                        {PIX::KEYMAP[PIX::KEY::TITLE], title},
                        {PIX::KEYMAP[PIX::KEY::RATE], rate},
                        {PIX::KEYMAP[PIX::KEY::FAV], fav},
                        {PIX::KEYMAP[PIX::KEY::COLOR], color},
                        {PIX::KEYMAP[PIX::KEY::FORMAT], format},
                        {PIX::KEYMAP[PIX::KEY::PIC_DATE], picDate},
                        {PIX::KEYMAP[PIX::KEY::PLACE], place},
                        {PIX::KEYMAP[PIX::KEY::ADD_DATE], QDateTime::currentDateTime()}};
    return this->db->insert(PIX::TABLEMAP[PIX::TABLE::IMAGES], imgMap);

}

bool DBActions::addPic(const QString &url)
{
    if(!this->db->checkExistance(PIX::TABLEMAP[PIX::TABLE::IMAGES], PIX::KEYMAP[PIX::KEY::URL], url))
    {
        QFileInfo info(url);
        auto title = info.baseName();
        auto format = info.suffix();
        auto sourceUrl = info.dir().path();

        PIX::DB picMap =
        {
            {PIX::KEY::URL, url},
            {PIX::KEY::TITLE, title},
            {PIX::KEY::FAV, "0"},
            {PIX::KEY::RATE, "0"},
            {PIX::KEY::COLOR, ""},
            {PIX::KEY::SOURCES_URL, sourceUrl},
            {PIX::KEY::PIC_DATE, info.birthTime().toString()},
            {PIX::KEY::FORMAT, format}
        };

        return this->insertPic(picMap);
    }

    return false;
}

bool DBActions::removePic(const QString &url)
{
    auto queryTxt = QString("DELETE FROM images WHERE url =  \"%1\"").arg(url);
    auto query = this->db->getQuery(queryTxt);
    if(query.exec())
    {
        queryTxt = QString("DELETE FROM images_tags WHERE url =  \"%1\"").arg(url);
        this->db->getQuery(queryTxt).exec();

        queryTxt = QString("DELETE FROM images_albums WHERE url =  \"%1\"").arg(url);
        this->db->getQuery(queryTxt).exec();

        queryTxt = QString("DELETE FROM images_notes WHERE url =  \"%1\"").arg(url);
        this->db->getQuery(queryTxt).exec();

        return true;
    }
    return false;
}

bool DBActions::favPic(const QString &url, const bool &fav )
{
    PIX::DB favedPic = {{PIX::KEY::FAV, fav ? "1" : "0"}};
    return this->db->update(PIX::TABLEMAP[PIX::TABLE::IMAGES], favedPic, QVariantMap({{PIX::KEYMAP[PIX::KEY::URL], url}}) );
}

bool DBActions::isFav(const QString &url)
{
    auto data = this->db->getDBData(QString("select * from images where url = '%1'").arg(url));

    if (data.isEmpty()) return false;

    return data.first()[PIX::KEY::FAV] == "1" ? true : false;
}

bool DBActions::addTag(const QString &tag)
{
    if (this->tag->tag(tag))
    {
        emit tagAdded(tag);
        return true;
    }

    return false;
}

bool DBActions::albumTag(const QString &tag, const QString &album)
{
    this->addTag(tag);

    return this->tag->tagAbstract(tag, PIX::KEYMAP[PIX::KEY::ALBUM], album);
}

bool DBActions::removePicTag(const QString &tag, const QString &url)
{
    PIX::DB tagMap {{PIX::KEY::URL, url}, {PIX::KEY::TAG, tag}};
    return this->db->remove(PIX::TABLEMAP[PIX::TABLE::IMAGES_TAGS], tagMap);
}

bool DBActions::removeAlbumTag(const QString &tag, const QString &album)
{
    PIX::DB tagMap {{PIX::KEY::TAG, tag}, {PIX::KEY::ALBUM, album}};
    return this->db->remove(PIX::TABLEMAP[PIX::TABLE::ALBUMS_TAGS], tagMap);
}

bool DBActions::cleanTags()
{
    return false;
}

bool DBActions::picAlbum(const QString &album, const QString &url)
{
    qDebug()<<"Trying to add to album"<<album<<url;
//    this->addAlbum(album);
    QVariantMap albumPic
    {
        {PIX::KEYMAP[PIX::KEY::URL], url},
        {PIX::KEYMAP[PIX::KEY::ALBUM], album},
        {PIX::KEYMAP[PIX::KEY::ADD_DATE], QDateTime::currentDateTime()}
    };
    return this->db->insert(PIX::TABLEMAP[PIX::TABLE::IMAGES_ALBUMS], albumPic);
}

QVariantList DBActions::searchFor(const QStringList &queries, const QString &queryTxt)
{
    QVariantList res;
    for(auto query : queries)
        res <<  this->db->get(PIX::getQuery("searchFor_").arg(query));

    return res;
}

QVariantList DBActions::getFolders(const QString &query)
{
    QVariantList res;
    auto data =  this->db->getDBData(query);

    /*Data model keys for to be used on MauiKit Icondelegate component */
    for(auto i : data)
        res << FMH::getFileInfo(i[PIX::KEY::URL]);

    return res;
}
