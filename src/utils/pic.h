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

#ifndef PIC_H
#define PIC_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>

#ifndef STATIC_MAUIKIT
#include "../pix_version.h"
#endif

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <MauiKit/utils.h>
#include <MauiKit/fmh.h>
#else
#include "utils.h"
#include "fmh.h"
#endif


namespace PIX
{
//Q_NAMESPACE

inline const static auto SettingPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/pix/");
inline const static auto NotifyDir = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation));

inline const static QString appName = QStringLiteral("pix");
inline const static QString displayName = QStringLiteral("Pix");
inline const static QString version = PIX_VERSION_STRING;
inline const static QString description = QStringLiteral("Image Viewer");
inline const static QString orgName = QStringLiteral("Maui");
inline const static QString orgDomain = QStringLiteral("org.maui.pix");

inline const static QString DBName = "collection.db";

inline static const QStringList getSourcePaths()
{
	static const QStringList defaultSources  = {FMH::PicturesPath, FMH::DownloadsPath};
	const auto sources = UTIL::loadSettings("Sources", "Settings", defaultSources).toStringList();
	qDebug()<< "SOURCES" << sources;
	return sources;
}

inline static void saveSourcePath(QStringList const& paths)
{
	auto sources = PIX::getSourcePaths();

	sources << paths;
	sources.removeDuplicates();

	qDebug()<< "Saving new sources" << sources;
	UTIL::saveSettings("Sources", sources, "Settings");
}

inline static void removeSourcePath(const QString &path)
{
	auto sources = PIX::getSourcePaths();
	sources.removeOne(path);

	UTIL::saveSettings("Sources", sources, "Settings");
}

}

#endif // PIC_H
