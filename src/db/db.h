#ifndef DB_H
#define DB_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QList>
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSqlDriver>
#include <QFileInfo>
#include <QDir>
#include <QVariantMap>

#include "../utils/pic.h"


class DB : public QObject
{
        Q_OBJECT
    private:
        QString name;
         QSqlDatabase m_db;
    public:
        explicit DB(QObject *parent = nullptr);
        ~ DB();

        void openDB(const QString &name);

        /*basic public actions*/
        void prepareCollectionDB() const;

        /* utils*/
        Q_INVOKABLE bool checkExistance(const QString &tableName, const QString &searchId, const QString &search);


    protected:
        QSqlQuery getQuery(const QString &queryTxt);

        bool insert(const QString &tableName, const QVariantMap &insertData);
        bool update(const QString &tableName, const PIX::DB &updateData, const QVariantMap &where);
        bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
        bool remove(const QString &tableName, const PIX::DB &removeData);

    signals:

    public slots:
};

#endif // DB_H
