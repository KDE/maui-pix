#include "db.h"
#include <QUuid>
#include <QString>
#include <QStringList>
#include <QSqlQuery>

DB::DB(QObject *parent) : QObject(parent)
{
    QDir collectionDBPath_dir(PIX::CollectionDBPath);
    if (!collectionDBPath_dir.exists())
        collectionDBPath_dir.mkpath(".");

    this->name = QUuid::createUuid().toString();
    if(!PIX::fileExists(PIX::CollectionDBPath + PIX::DBName))
    {
        this->openDB(this->name);
        qDebug()<<"Collection doesn't exists, trying to create it" << PIX::CollectionDBPath + PIX::DBName;
        this->prepareCollectionDB();
    }else this->openDB(this->name);
}

DB::~DB()
{
    this->m_db.close();
}

void DB::openDB(const QString &name)
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

void DB::prepareCollectionDB() const
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

bool DB::checkExistance(const QString &tableName, const QString &searchId, const QString &search)
{
    auto queryStr = QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(searchId, tableName, searchId, search);
    auto query = this->getQuery(queryStr);

    if (query.exec())
    {
        if (query.next()) return true;
    }else qDebug()<<query.lastError().text();

    return false;
}

QSqlQuery DB::getQuery(const QString &queryTxt)
{
    QSqlQuery query(queryTxt, this->m_db);
    return query;
}

bool DB::insert(const QString &tableName, const QVariantMap &insertData)
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

bool DB::update(const QString &tableName, const PIX::DB &updateData, const QVariantMap &where)
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
        set.append(PIX::KEYMAP[key]+" = '"+updateData[key]+"'");

    QStringList condition;
    for (auto key : where.keys())
        condition.append(key+" = '"+where[key].toString()+"'");

    QString sqlQueryString = "UPDATE " + tableName + " SET " + QString(set.join(",")) + " WHERE " + QString(condition.join(",")) ;
    auto query = this->getQuery(sqlQueryString);
    qDebug()<<sqlQueryString;
    return query.exec();
}

bool DB::update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id)
{
    auto queryStr = QString("UPDATE %1 SET %2 = \"%3\" WHERE %4 = \"%5\"").arg(table, column, newValue.toString().replace("\"","\"\""), op.toString(), id);
    auto query = this->getQuery(queryStr);
    return query.exec();
}

bool DB::remove(const QString &tableName, const PIX::DB &removeData)
{
    if (tableName.isEmpty())
    {
        qDebug()<<QStringLiteral("Fatal error on removing! The table name is empty!");
        return false;

    } else if (removeData.isEmpty())
    {
        qDebug()<<QStringLiteral("Fatal error on insert! The removeData is empty!");
        return false;
    }

    QString strValues;
        auto i = 0;
    for (auto key : removeData.keys())
    {
        strValues.append(QString("%1 = \"%2\"").arg(PIX::KEYMAP[key], removeData[key]));
        i++;

        if(removeData.keys().size() > 1 && i<removeData.keys().size())
            strValues.append(" AND ");
    }

    QString sqlQueryString = "DELETE FROM " + tableName + " WHERE " + strValues;
    qDebug()<< sqlQueryString;

    return this->getQuery(sqlQueryString).exec();
}
