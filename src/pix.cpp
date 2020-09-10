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

#include "pix.h"
#include <QDesktopServices>

using namespace PIX;
#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

Pix::Pix(QObject *parent) : QObject(parent)
{
	qDebug() << "Getting settings info from: " << PIX::SettingPath;
}

QVariantList Pix::sourcesModel() const
{
	QVariantList res;
	const auto sources = PIX::getSourcePaths();
	return std::accumulate(sources.constBegin(), sources.constEnd(), res, [](QVariantList &res, const QString &url)
	{
		res << FMH::getDirInfo(url);
		return res;
	});
}

QStringList Pix::sources() const
{
	return PIX::getSourcePaths();
}

void Pix::openPics(const QList<QUrl> &pics)
{
	emit this->viewPics(QUrl::toStringList(pics));
}

void Pix::refreshCollection()
{
	const auto sources = PIX::getSourcePaths();
	qDebug()<< "getting default sources to look up" << sources;
}

void Pix::showInFolder(const QStringList &urls)
{
	for(const auto &url : urls)
		QDesktopServices::openUrl(FMH::fileDir(url));
}

void Pix::addSources(const QStringList &paths)
{
	PIX::saveSourcePath(paths);
	emit sourcesChanged();
}

void Pix::removeSources(const QString &path)
{
	PIX::removeSourcePath(path);
	emit sourcesChanged();
}
