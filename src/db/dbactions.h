#ifndef DBACTIONS_H
#define DBACTIONS_H

#include <QObject>
#include "db.h"

class DBActions : public DB
{
    public:
        DBActions(QObject *parent = nullptr);
        ~DBActions();

        PIX::DB_LIST getDBData(const QString &queryTxt);
        QVariantList getDBDataQML(const QString &queryTxt);

        bool execQuery(const QString &queryTxt);

        void addPic(const PIX::DB &img);

};

#endif // DBACTIONS_H
