// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


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
#include "utils/pic.h"

using namespace std;

class Pix : public QObject
{
	Q_OBJECT
    Q_PROPERTY(QStringList sources READ sources NOTIFY sourcesChanged FINAL)
public:
	explicit Pix(QObject* parent = nullptr);

public slots:
    QStringList sources() const
    {
        return PIX::getSourcePaths();
    }

	void addSources(const QStringList &paths);
    void removeSources(const QString &path);

    void openPics(const QList<QUrl> &pics);
	void refreshCollection();
	/*File actions*/
   static void showInFolder(const QStringList &urls);

   QVariantList getTagUrls(const QString &tag);


signals:
	void refreshViews(QVariantMap tables);
	void viewPics(QStringList pics);
    void sourcesChanged();
};
#endif // PIX_H
