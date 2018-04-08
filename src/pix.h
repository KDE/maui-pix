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

    Q_INVOKABLE void openPics(const QStringList &pics);

    Q_INVOKABLE void refreshCollection();

    Q_INVOKABLE QVariantList getList(const QStringList &urls);
    Q_INVOKABLE bool run(const QString &query);

    Q_INVOKABLE static QString pixColor();
    Q_INVOKABLE static void saveSettings(const QString &key, const QVariant &value, const QString &group);
    Q_INVOKABLE static QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue);

    Q_INVOKABLE static int screenGeometry(QString &side);
    Q_INVOKABLE static int cursorPos(QString &axis);

    Q_INVOKABLE static QString homeDir();

    Q_INVOKABLE static QVariantList getDirs(const QString &pathUrl);
    Q_INVOKABLE static QVariantMap getParentDir(const QString &path);   

    /*KDE*/
    Q_INVOKABLE static QVariantList openWith(const QString &url);
    Q_INVOKABLE static void runApplication(const QString &exec, const QString &url);

    Q_INVOKABLE static QVariantList getDevices();
    Q_INVOKABLE static bool sendToDevice(const QString &name, const QString &id, const QString &url);

    Q_INVOKABLE static void attachToEmail(const QString &url);

    /*File actions*/
    Q_INVOKABLE bool removeFile(const QString &url);
    Q_INVOKABLE void showInFolder(const QString &url);



private:
    FileLoader *fileLoader;

    void populateDB(const QStringList &paths);

signals:
    void refreshViews(QVariantMap tables);
    void viewPics(QVariantList pics);

};



#endif // PIX_H
