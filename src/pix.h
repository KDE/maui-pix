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

#ifndef PIX_H
#define PIX_H


#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QVariantList>
#include "db/dbactions.h"

using namespace std;

class FileLoader;
class Pix : public DBActions
{
    Q_OBJECT

public:
    explicit Pix(QObject* parent = nullptr);
    ~Pix();

    /*UTILS*/
    Q_INVOKABLE void openPics(const QStringList &pics);

    Q_INVOKABLE void refreshCollection();

    Q_INVOKABLE bool run(const QString &query);
    /*File actions*/
    Q_INVOKABLE bool removeFile(const QString &url);
    Q_INVOKABLE void showInFolder(const QStringList &urls);

private:
    FileLoader *fileLoader;

    void populateDB(const QStringList &paths);

signals:
    void refreshViews(QVariantMap tables);
    void viewPics(QVariantList pics);
};
#endif // PIX_H
