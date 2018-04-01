#ifndef DBACTIONS_H
#define DBACTIONS_H

#include <QObject>
#include "db.h"

class DBActions : public DB
{
        Q_OBJECT
    public:
        explicit DBActions(QObject *parent = nullptr);
        ~DBActions();

        PIX::DB_LIST getDBData(const QString &queryTxt);

        bool execQuery(const QString &queryTxt);

        void addPic(const PIX::DB &img);

        /* actions on model */
        Q_INVOKABLE bool favPic(const QString &url, const bool &fav);
        Q_INVOKABLE bool isFav(const QString &url);

        Q_INVOKABLE bool addTag(const QString &tag);
        Q_INVOKABLE bool picTag(const QString &tag, const QString &url);
        Q_INVOKABLE bool albumTag(const QString &tag, const QString &album);
        Q_INVOKABLE bool removePicTag(const QString &tag, const QString &url);
        Q_INVOKABLE bool removeAlbumTag(const QString &tag, const QString &album);

        Q_INVOKABLE bool addAlbum(const QString &album);
        Q_INVOKABLE bool picAlbum(const QString &album, const QString &url);



        /* utils */
        Q_INVOKABLE QVariantList getFolders();
        Q_INVOKABLE QVariantList get(const QString &queryTxt);


};

#endif // DBACTIONS_H
