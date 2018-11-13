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

#ifndef DBACTIONS_H
#define DBACTIONS_H

#include <QObject>
#include "../utils/pic.h"

class DB;
class Tagging;
class DBActions : public QObject
{
    Q_OBJECT
public:
    explicit DBActions(QObject *parent = nullptr);
    ~DBActions();

    Tagging *tag;
    bool execQuery(const QString &queryTxt);

    bool insertPic(const PIX::DB &img);
    Q_INVOKABLE bool addPic(const QString &url);
    Q_INVOKABLE bool removePic(const QString &url);

    /* actions on model */
    Q_INVOKABLE bool favPic(const QString &url, const bool &fav);
    Q_INVOKABLE bool isFav(const QString &url);

    Q_INVOKABLE bool addTag(const QString &tag);
    Q_INVOKABLE bool albumTag(const QString &tag, const QString &album);
    Q_INVOKABLE bool removePicTag(const QString &tag, const QString &url);
    Q_INVOKABLE bool removeAlbumTag(const QString &tag, const QString &album);
    Q_INVOKABLE bool cleanTags();

    Q_INVOKABLE bool picAlbum(const QString &album, const QString &url);

    Q_INVOKABLE QVariantList searchFor(const QStringList &queries, const QString &queryTxt);
    /* utils */
    Q_INVOKABLE QVariantList getFolders(const QString &query);

private:
    DB *db;

signals:
    void tagAdded(QString tag);
};

#endif // DBACTIONS_H
