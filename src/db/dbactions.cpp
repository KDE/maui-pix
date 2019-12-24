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

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

DBActions::DBActions(QObject *parent) : DB(parent)
{
    qDebug() << "Getting collectionDB info from: " << PIX::CollectionDBPath;
    qDebug()<< "Starting DBActions";
    this->tag = Tagging::getInstance();
}

DBActions *DBActions::instance = nullptr;
DBActions *DBActions::getInstance()
{
    if(!instance)
    {
        qDebug() << "getInstance(): First DBActions instance\n";
        instance = new DBActions();
        return instance;
    } else
    {
        qDebug()<< "getInstance(): previous DBActions instance\n";
        return instance;
    }
}

bool DBActions::execQuery(const QString &queryTxt)
{
    auto query = this->getQuery(queryTxt);
    return query.exec();
}

bool DBActions::insertPic(const FMH::MODEL &img)
{
    auto url = img[FMH::MODEL_KEY::URL];
    auto title = img[FMH::MODEL_KEY::TITLE];
    auto rate = img[FMH::MODEL_KEY::RATE];
    auto fav = img[FMH::MODEL_KEY::FAV];
    auto color = img[FMH::MODEL_KEY::COLOR];
    auto sourceUrl = img[FMH::MODEL_KEY::SOURCE];
    auto picDate = img[FMH::MODEL_KEY::DATE];
    auto format = img[FMH::MODEL_KEY::FORMAT];

    qDebug()<< "writting to db: "<<title<<url;
    /* first needs to insert album and artist*/
    QVariantMap sourceMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], sourceUrl}};
    this->insert(PIX::TABLEMAP[PIX::TABLE::SOURCES], sourceMap);


    QVariantMap imgMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SOURCE], sourceUrl},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], title},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::RATE], rate},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::FAV], fav},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR], color},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::FORMAT], format},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::DATE], picDate},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::PLACE], QString()},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime().toString(Qt::TextDate)}};

    return this->insert(PIX::TABLEMAP[PIX::TABLE::IMAGES], imgMap);

}

bool DBActions::addPic(const QString &url)
{
    if(!this->checkExistance(PIX::TABLEMAP[PIX::TABLE::IMAGES], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url))
    {
        QFileInfo info(url);
        auto title = info.baseName();
        auto format = info.suffix();
        auto sourceUrl = info.dir().path();

        FMH::MODEL picMap =
        {
            {FMH::MODEL_KEY::URL, url},
            {FMH::MODEL_KEY::TITLE, title},
            {FMH::MODEL_KEY::FAV, "0"},
            {FMH::MODEL_KEY::RATE, "0"},
            {FMH::MODEL_KEY::COLOR, ""},
            {FMH::MODEL_KEY::SOURCE, sourceUrl},
            {FMH::MODEL_KEY::DATE, info.birthTime().toString(Qt::TextDate)},
            {FMH::MODEL_KEY::FORMAT, format}
        };

        return this->insertPic(picMap);
    }

    return false;
}

bool DBActions::removePic(const QString &url)
{
    auto queryTxt = QString("DELETE FROM images WHERE url =  \"%1\"").arg(url);
    auto query = this->getQuery(queryTxt);
    if(query.exec())
    {
        queryTxt = QString("DELETE FROM images_tags WHERE url =  \"%1\"").arg(url);
        this->getQuery(queryTxt).exec();

        queryTxt = QString("DELETE FROM images_albums WHERE url =  \"%1\"").arg(url);
        this->getQuery(queryTxt).exec();

        queryTxt = QString("DELETE FROM images_notes WHERE url =  \"%1\"").arg(url);
        this->getQuery(queryTxt).exec();

        return true;
    }
    return false;
}

bool DBActions::deletePic(const QString &url)
{
    QFile file(url);
    if(!file.exists()) return false;

    if(file.remove())
        return this->removePic(url);

    return false;
}

bool DBActions::favPic(const QString &url, const bool &fav )
{
    if(!this->checkExistance("images", "url", url))
        if(!this->addPic(url))
            return false;

    FMH::MODEL favedPic = {{FMH::MODEL_KEY::FAV, fav ? "1" : "0"}};
    return this->update(PIX::TABLEMAP[PIX::TABLE::IMAGES], favedPic, QVariantMap({{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url}}) );
}

bool DBActions::isFav(const QString &url)
{
    const auto data = this->getDBData(QString("select * from images where url = '%1'").arg(url));

    if (data.isEmpty()) return false;

    return data.first()[FMH::MODEL_KEY::FAV] == "1" ? true : false;
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

    return this->tag->tagAbstract(tag, FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album);
}

bool DBActions::removePicTag(const QString &tag, const QString &url)
{
    FMH::MODEL tagMap {{FMH::MODEL_KEY::URL, url}, {FMH::MODEL_KEY::TAG, tag}};
    return this->remove(PIX::TABLEMAP[PIX::TABLE::IMAGES_TAGS], tagMap);
}

bool DBActions::removeAlbumTag(const QString &tag, const QString &album)
{
    FMH::MODEL tagMap {{FMH::MODEL_KEY::TAG, tag}, {FMH::MODEL_KEY::ALBUM, album}};
    return this->remove(PIX::TABLEMAP[PIX::TABLE::ALBUMS_TAGS], tagMap);
}

bool DBActions::cleanTags()
{
    return false;
}

bool DBActions::addAlbum(const QString &album)
{
    QVariantMap albumMap
    {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime()}
    };

    if(this->insert(PIX::TABLEMAP[PIX::TABLE::ALBUMS], albumMap))
    {
        emit this->albumAdded(album);
        return true;
    }

    return false;
}

bool DBActions::picAlbum(const QString &album, const QString &url)
{
    qDebug()<<"Trying to add to album"<<album<<url;
    this->addAlbum(album);
    QVariantMap albumPic
    {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime()}
    };
    return this->insert(PIX::TABLEMAP[PIX::TABLE::IMAGES_ALBUMS], albumPic);
}

QVariantList DBActions::searchFor(const QStringList &queries, const QString &queryTxt)
{
    QVariantList res;
    for(auto query : queries)
        res <<  this->get(PIX::getQuery("searchFor_").arg(query));

    return res;
}

FMH::MODEL_LIST DBActions::getFolders(const QString &query)
{
    FMH::MODEL_LIST res;
    auto data =  this->getDBData(query);

    /*Data model keys for to be used on MauiKit Icondelegate component */
    for(auto i : data)
        res << FMH::getFileInfoModel(i[FMH::MODEL_KEY::URL]);

    return res;
}

FMH::MODEL_LIST DBActions::getDBData(const QString &queryTxt, std::function<void(FMH::MODEL &item)> modifier)
{
    FMH::MODEL_LIST mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            FMH::MODEL data;
            for(const auto &key : FMH::MODEL_NAME.keys())
                if(query.record().indexOf(FMH::MODEL_NAME[key]) > -1)
                    data.insert(key, query.value(FMH::MODEL_NAME[key]).toString());
            if(modifier)
                modifier(data);
            mapList << data;
        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}

QVariantList DBActions::get(const QString &queryTxt)
{
    return this->getList(queryTxt);
}
