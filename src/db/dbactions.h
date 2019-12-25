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
#include "db.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

class Tagging;
class DBActions : public DB
{
    Q_OBJECT
public:

    static DBActions *getInstance();
    Tagging *tag;

    bool execQuery(const QString &queryTxt);

    bool insertPic(const FMH::MODEL &img);
    bool addPic(const QUrl &url);
    bool removePic(const QString &url);

    /* actions on model */
    bool cleanTags();

    QVariantList searchFor(const QStringList &queries, const QString &queryTxt);

    /* utils */
    FMH::MODEL_LIST getFolders(const QString &query);
    FMH::MODEL_LIST getDBData(const QString &queryTxt, std::function<bool (FMH::MODEL &)> modifier = nullptr);

public slots:
    QVariantList get(const QString &queryTxt);
    bool deletePic(const QString &url);

private:
    static DBActions* instance;
    explicit DBActions(QObject *parent = nullptr);

signals:
    void picRemoved();
};

#endif // DBACTIONS_H
