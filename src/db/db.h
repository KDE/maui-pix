#ifndef DB_H
#define DB_H

#include <QObject>

class DB : public QObject
{
        Q_OBJECT
    public:
        explicit DB(QObject *parent = nullptr);

    signals:

    public slots:
};

#endif // DB_H