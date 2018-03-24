#ifndef DBACTIONS_H
#define DBACTIONS_H

#include <QObject>
#include "db.h"

class DBActions : public DB
{
    public:
        DBActions(QObject *parent = nullptr);
        ~DBActions();
};

#endif // DBACTIONS_H
