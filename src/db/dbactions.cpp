#include "dbactions.h"

DBActions::DBActions(QObject *parent) : DB(parent)
{
    qDebug() << "Getting collectionDB info from: " << PIX::CollectionDBPath;

    qDebug()<< "Starting DBActions";
}

DBActions::~DBActions()
{

}

PIX::DB_LIST DBActions::getDBData(const QString &queryTxt)
{
    PIX::DB_LIST mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            PIX::DB data;
            for(auto key : PIX::KEYMAP.keys())
                if(query.record().indexOf(PIX::KEYMAP[key])>-1)
                    data.insert(key, query.value(PIX::KEYMAP[key]).toString());

            mapList<< data;
        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}

QVariantList DBActions::get(const QString &queryTxt)
{
    QVariantList mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            QVariantMap data;
            for(auto key : PIX::KEYMAP.keys())
                if(query.record().indexOf(PIX::KEYMAP[key])>-1)
                    data[PIX::KEYMAP[key]] = query.value(PIX::KEYMAP[key]).toString();

            mapList<< data;
        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}

bool DBActions::execQuery(const QString &queryTxt)
{
    auto query = this->getQuery(queryTxt);
    return query.exec();
}

void DBActions::addPic(const PIX::DB &img)
{
    auto query = this->getQuery("PRAGMA synchronous=OFF");
    if(query.exec())
    {
        auto url = img[PIX::KEY::URL];
        auto title = img[PIX::KEY::TITLE];
        auto rate = img[PIX::KEY::RATE];
        auto fav = img[PIX::KEY::FAV];
        auto color = img[PIX::KEY::COLOR];
        auto addDate = img[PIX::KEY::ADD_DATE];
        auto sourceUrl = img[PIX::KEY::SOURCES_URL];
        auto picDate = img[PIX::KEY::PIC_DATE];
        auto note = img[PIX::KEY::NOTE];
        auto place = img[PIX::KEY::PLACE];
        auto format = img[PIX::KEY::FORMAT];

        qDebug()<< "writting to db: "<<title<<url;
        /* first needs to insert album and artist*/
        QVariantMap sourceMap {{PIX::KEYMAP[PIX::KEY::URL],sourceUrl}};
        insert(PIX::TABLEMAP[PIX::TABLE::SOURCES], sourceMap);


        QVariantMap imgMap {{PIX::KEYMAP[PIX::KEY::URL], url},
                            {PIX::KEYMAP[PIX::KEY::SOURCES_URL], sourceUrl},
                            {PIX::KEYMAP[PIX::KEY::TITLE], title},
                            {PIX::KEYMAP[PIX::KEY::RATE], rate},
                            {PIX::KEYMAP[PIX::KEY::FAV], fav},
                            {PIX::KEYMAP[PIX::KEY::COLOR], color},
                            {PIX::KEYMAP[PIX::KEY::FORMAT], format},
                            {PIX::KEYMAP[PIX::KEY::PIC_DATE], picDate},
                            {PIX::KEYMAP[PIX::KEY::NOTE], note},
                            {PIX::KEYMAP[PIX::KEY::PLACE], place},
                            {PIX::KEYMAP[PIX::KEY::ADD_DATE], QDateTime::currentDateTime()}};
        insert(PIX::TABLEMAP[PIX::TABLE::IMAGES], imgMap);
    }else
    {
        qDebug()<< "Failed to insert async";
    }

}

bool DBActions::favPic(const QString &url, const bool &fav )
{
    PIX::DB favedPic = {{PIX::KEY::FAV, fav ? "1" : "0"}};
    return this->update(PIX::TABLEMAP[PIX::TABLE::IMAGES], favedPic, QVariantMap({{PIX::KEYMAP[PIX::KEY::URL], url}}) );
}

bool DBActions::isFav(const QString &url)
{
    auto data = this->getDBData(QString("select * from images where url = '%1'").arg(url));

    if (data.isEmpty()) return false;

    return data.first()[PIX::KEY::FAV] == "1" ? true : false;
}

QVariantList DBActions::getFolders()
{
    QVariantList res;
    auto data = this->getDBData("select * from sources");

    for(auto i : data)
    {
        QVariantMap map;
        map.insert(PIX::KEYMAP[PIX::KEY::URL], i[PIX::KEY::URL]);
        map.insert("folder", QFileInfo(i[PIX::KEY::URL]).baseName());
        res << map;
}
    return res;

}
