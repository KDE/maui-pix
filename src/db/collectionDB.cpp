/*
   Babe - tiny music player
   Copyright (C) 2017  Camilo Higuita
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

   */


#include "collectionDB.h"
#include <QUuid>
#include <QString>
#include <QStringList>

using namespace PIX;

CollectionDB::CollectionDB(QObject *parent) : QObject(parent)
{
    this->name = QUuid::createUuid().toString();
    if(!PIX::fileExists(PIX::CollectionDBPath + PIX::DBName))
    {
        this->openDB(this->name);
        qDebug()<<"Collection doesn't exists, trying to create it" << PIX::CollectionDBPath + PIX::DBName;
        this->prepareCollectionDB();
    }else this->openDB(this->name);
}

CollectionDB::~CollectionDB()
{
    this->m_db.close();
}


void CollectionDB::closeConnection()
{
    qDebug()<<"CLOSING COLLECTIONDB";
}

void CollectionDB::prepareCollectionDB() const
{
    QSqlQuery query(this->m_db);

    QFile file(":/db/script.sql");

    if (!file.exists())
    {
        QString log = QStringLiteral("Fatal error on build database. The file '");
        log.append(file.fileName() + QStringLiteral("' for database and tables creation query cannot be not found!"));
        qDebug()<<log;
        return;
    }

    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug()<<QStringLiteral("Fatal error on try to create database! The file with sql queries for database creation cannot be opened!");
        return;
    }

    bool hasText;
    QString line;
    QByteArray readLine;
    QString cleanedLine;
    QStringList strings;

    while (!file.atEnd())
    {
        hasText     = false;
        line        = "";
        readLine    = "";
        cleanedLine = "";
        strings.clear();
        while (!hasText)
        {
            readLine    = file.readLine();
            cleanedLine = readLine.trimmed();
            strings     = cleanedLine.split("--");
            cleanedLine = strings.at(0);
            if (!cleanedLine.startsWith("--") && !cleanedLine.startsWith("DROP") && !cleanedLine.isEmpty())
                line += cleanedLine;
            if (cleanedLine.endsWith(";"))
                break;
            if (cleanedLine.startsWith("COMMIT"))
                hasText = true;
        }
        if (!line.isEmpty())
        {
            if (!query.exec(line))
            {
                qDebug()<<"exec failed"<<query.lastQuery()<<query.lastError();
            }

        } else qDebug()<<"exec wrong"<<query.lastError();
    }
    file.close();
}

bool CollectionDB::check_existance(const QString &tableName, const QString &searchId,const QString &search)
{
    auto queryStr = QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(searchId, tableName, searchId, search);
    auto query = this->getQuery(queryStr);

    if (query.exec())
    {
        if (query.next()) return true;
    }else qDebug()<<query.lastError().text();

    return false;
}

bool CollectionDB::insert(const QString &tableName, const QVariantMap &insertData)
{
    if (tableName.isEmpty())
    {
        qDebug()<<QStringLiteral("Fatal error on insert! The table name is empty!");
        return false;

    } else if (insertData.isEmpty())
    {
        qDebug()<<QStringLiteral("Fatal error on insert! The insertData is empty!");
        return false;
    }

    QStringList strValues;
    QStringList fields = insertData.keys();
    QVariantList values = insertData.values();
    int totalFields = fields.size();
    for (int i = 0; i < totalFields; ++i)
        strValues.append("?");

    QString sqlQueryString = "INSERT INTO " + tableName + " (" + QString(fields.join(",")) + ") VALUES(" + QString(strValues.join(",")) + ")";
    QSqlQuery query(this->m_db);
    query.prepare(sqlQueryString);

    int k = 0;
    foreach (const QVariant &value, values)
        query.bindValue(k++, value);

    return query.exec();
}

bool CollectionDB::update(const QString &tableName, const PIX::DB &updateData, const QVariantMap &where)
{
    if (tableName.isEmpty())
    {
        qDebug()<<QStringLiteral("Fatal error on insert! The table name is empty!");
        return false;
    } else if (updateData.isEmpty())
    {
        qDebug()<<QStringLiteral("Fatal error on insert! The insertData is empty!");
        return false;
    }

    QStringList set;
    for (auto key : updateData.keys())
        set.append(KEYMAP[key]+" = '"+updateData[key]+"'");

    QStringList condition;
    for (auto key : where.keys())
        condition.append(key+" = '"+where[key].toString()+"'");

    QString sqlQueryString = "UPDATE " + tableName + " SET " + QString(set.join(",")) + " WHERE " + QString(condition.join(",")) ;
    auto query = this->getQuery(sqlQueryString);
    qDebug()<<sqlQueryString;
    return query.exec();
}

bool CollectionDB::update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id)
{
    auto queryStr = QString("UPDATE %1 SET %2 = \"%3\" WHERE %4 = \"%5\"").arg(table, column, newValue.toString().replace("\"","\"\""), op.toString(), id);
    auto query = this->getQuery(queryStr);
    return query.exec();
}

bool CollectionDB::execQuery(const QString &queryTxt)
{
    auto query = this->getQuery(queryTxt);
    return query.exec();
}

void CollectionDB::openDB(const QString &name)
{
    if(!QSqlDatabase::contains(name))
    {
        this->m_db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), name);
        this->m_db.setDatabaseName(PIX::CollectionDBPath + PIX::DBName);
    }

    if (!this->m_db.isOpen())
    {
        if(!this->m_db.open())
            qDebug()<<"ERROR OPENING DB"<<this->m_db.lastError().text()<<m_db.connectionName();
    }
}

void CollectionDB::addPic(const DB &img)
{
    auto query = this->getQuery("PRAGMA synchronous=OFF");
    if(query.exec())
    {
        auto url = img[KEY::URL];
        auto title = img[KEY::TITLE];
        auto rate = img[KEY::RATE];
        auto fav = img[KEY::FAV];
        auto color = img[KEY::COLOR];
        auto addDate = img[KEY::ADD_DATE];
        auto sourceUrl = img[KEY::SOURCES_URL];
        auto picDate = img[KEY::PIC_DATE];
        auto note = img[KEY::NOTE];
        auto place = img[KEY::PLACE];
        auto format = img[KEY::FORMAT];

        qDebug()<< "writting to db: "<<title<<url;
        /* first needs to insert album and artist*/
        QVariantMap sourceMap {{KEYMAP[KEY::URL],sourceUrl}};
        insert(TABLEMAP[TABLE::SOURCES],sourceMap);


        QVariantMap imgMap {{KEYMAP[KEY::URL], url},
                            {KEYMAP[KEY::SOURCES_URL], sourceUrl},
                            {KEYMAP[KEY::TITLE], title},
                            {KEYMAP[KEY::RATE], rate},
                            {KEYMAP[KEY::FAV], fav},
                            {KEYMAP[KEY::COLOR], color},
                            {KEYMAP[KEY::FORMAT], format},
                            {KEYMAP[KEY::PIC_DATE], picDate},
                            {KEYMAP[KEY::NOTE], note},
                            {KEYMAP[KEY::PLACE], place},
                            {KEYMAP[KEY::ADD_DATE], QDateTime::currentDateTime()}};
        insert(TABLEMAP[TABLE::IMAGES],imgMap);
    }else
    {
        qDebug()<< "Failed to insert async";
    }

    emit imgInserted();
}

DB_LIST CollectionDB::getDBData(const QString &queryTxt)
{
    DB_LIST mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            DB data;
            for(auto key : KEYMAP.keys())
                if(query.record().indexOf(KEYMAP[key])>-1)
                    data.insert(key, query.value(KEYMAP[key]).toString());

            mapList<< data;
        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}


QSqlQuery CollectionDB::getQuery(const QString &queryTxt)
{
    QSqlQuery query(queryTxt, this->m_db);
    return query;
}


