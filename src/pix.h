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

#pragma once
#include <QString>
#include <QUrl>
#include <QVariantList>

class Gallery;
class Pix : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY_MOVE(Pix)
    Q_PROPERTY(QVariantList sourcesModel READ sourcesModel NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(QStringList sources READ sources NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(Gallery* allImagesModel READ allImagesModel CONSTANT FINAL)

public:
    explicit Pix(QObject * = nullptr);

    static Pix *instance();

    static const QStringList getSourcePaths();
    static void saveSourcePath(QStringList const &);
    static void removeSourcePath(const QString &);
    static QUrl cameraPath();
    static QUrl screenshotsPath();

    Gallery* allImagesModel();

public Q_SLOTS:
    QVariantList sourcesModel() const;
    QStringList sources() const;

    void addSources(const QStringList &);
    void removeSources(const QString &);

    void openPics(const QList<QUrl> &);

    /*File actions*/
    static void showInFolder(const QStringList &);

private:
    mutable Gallery* m_allImagesModel;

Q_SIGNALS:
    void viewPics(QStringList pics);
    void sourcesChanged();
};
