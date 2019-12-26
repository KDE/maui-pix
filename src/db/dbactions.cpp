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

DBActions::DBActions(QObject *parent) : DB(parent)
{
    qDebug() << "Getting collectionDB info from: " << PIX::CollectionDBPath;
    qDebug()<< "Starting DBActions";
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
    QVariantMap sourceMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], img[FMH::MODEL_KEY::SOURCE]}};
    this->insert(PIX::TABLEMAP[PIX::TABLE::SOURCES], sourceMap);
    return this->insert(PIX::TABLEMAP[PIX::TABLE::IMAGES], FMH::toMap(img));
}

bool DBActions::addPic(const QUrl &url)
{
    if(!this->checkExistance(PIX::TABLEMAP[PIX::TABLE::IMAGES], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url.toString()))
    {
        const QFileInfo info(url.toLocalFile());
        FMH::MODEL picMap =
        {
            {FMH::MODEL_KEY::URL, url.toString()},
            {FMH::MODEL_KEY::TITLE,  info.baseName()},
            {FMH::MODEL_KEY::RATE, "0"},
            {FMH::MODEL_KEY::COLOR, ""},
            {FMH::MODEL_KEY::SIZE, QString::number(info.size())},
            {FMH::MODEL_KEY::SOURCE, FMH::fileDir(url)},
            {FMH::MODEL_KEY::DATE, info.birthTime().toString(Qt::TextDate)},
            {FMH::MODEL_KEY::ADDDATE, QDateTime::currentDateTime().toString(Qt::TextDate)},
            {FMH::MODEL_KEY::FORMAT, info.suffix()}
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

QVariantList DBActions::searchFor(const QStringList &queries, const QString &queryTxt)
{
    QVariantList res;
    for(auto query : queries)
        res <<  this->get(PIX::getQuery("searchFor_").arg(query));

    return res;
}

FMH::MODEL_LIST DBActions::getFolders(const QString &query)
{
    const auto data = this->getDBData(query);
    return std::accumulate(data.begin(), data.end(), FMH::MODEL_LIST(), [](FMH::MODEL_LIST &res, const FMH::MODEL &item){
        res << FMH::getFileInfoModel(item[FMH::MODEL_KEY::URL]);
        return res;
    });
}

FMH::MODEL_LIST DBActions::getDBData(const QString &queryTxt, std::function<bool(FMH::MODEL &item)> modifier)
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
            {
                if(!modifier(data))
                    continue;
            }

            mapList << data;
        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}

QVariantList DBActions::get(const QString &queryTxt)
{
    return this->getList(queryTxt);
}
