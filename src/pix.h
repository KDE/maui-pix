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
#include <QUrl>
#include <QVariantList>

using namespace std;

class Pix : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList sourcesModel READ sourcesModel NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(QStringList sources READ sources NOTIFY sourcesChanged FINAL)

public:
    static Pix *instance()
    {
        static Pix pix;
        return &pix;
    }

    Pix(const Pix &) = delete;
    Pix &operator=(const Pix &) = delete;
    Pix(Pix &&) = delete;
    Pix &operator=(Pix &&) = delete;

    inline static const QStringList getSourcePaths();
    inline static void saveSourcePath(QStringList const &paths);
    inline static void removeSourcePath(const QString &path);

public slots:
    QVariantList sourcesModel() const;
    QStringList sources() const;

    void addSources(const QStringList &paths);
    void removeSources(const QString &path);

    void openPics(const QList<QUrl> &pics);
    void refreshCollection();
    /*File actions*/
    static void showInFolder(const QStringList &urls);

private:
    explicit Pix(QObject *parent = nullptr);

signals:
    void refreshViews(QVariantMap tables);
    void viewPics(QStringList pics);
    void sourcesChanged();
};
#endif // PIX_H
