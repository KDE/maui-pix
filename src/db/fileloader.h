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
#ifndef FILELOADER_H
#define FILELOADER_H

#include <QObject>
#include <QDirIterator>
#include <QFileInfo>
#include <QThread>

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <MauiKit/fmh.h>
#else
#include "fmh.h"
#endif

class FileLoader : public QObject
{
	Q_OBJECT

public:
	FileLoader(QObject *parent = nullptr) : QObject(parent)
	{
		this->moveToThread(&t);
		connect(this, &FileLoader::start, this, &FileLoader::getPics);
		this->t.start();
	}

	~FileLoader()
	{
		t.quit();
		t.wait();
	}

	void requestPath(const QList<QUrl> &urls, const bool &recursive)
	{
		qDebug()<<"FROM file loader"<< urls;
		emit this->start(urls, recursive);
	}

private slots:
	void getPics(QList<QUrl> paths, bool recursive)
	{
		qDebug()<<"GETTING IMAGES";
		const uint m_bsize = 5000;
		uint i = 0;
		uint batch = 0;
		FMH::MODEL_LIST res;
		FMH::MODEL_LIST res_batch;
		QList<QUrl> urls;

		for(const auto &path : paths)
		{
			if (QFileInfo(path.toLocalFile()).isDir() && path.isLocalFile() && FMH::fileExists(path))
			{
				QDirIterator it(path.toLocalFile(), FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], QDir::Files, recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags);

				while (it.hasNext())
				{
					const auto url = QUrl::fromLocalFile(it.next());
					urls << url;
					const QFileInfo info(url.toLocalFile());
					FMH::MODEL map =
					{
						{FMH::MODEL_KEY::URL, url.toString()},
						{FMH::MODEL_KEY::TITLE,  info.baseName()},
						{FMH::MODEL_KEY::SIZE, QString::number(info.size())},
						{FMH::MODEL_KEY::SOURCE, FMH::fileDir(url)},
						{FMH::MODEL_KEY::DATE, info.birthTime().toString(Qt::TextDate)},
						{FMH::MODEL_KEY::MODIFIED, info.lastModified().toString(Qt::TextDate)},
						{FMH::MODEL_KEY::FORMAT, info.suffix()}
					};

					emit itemReady(map);
					res << map;
					res_batch << map;
					i++;

					if(i == m_bsize) //send a batch
					{
						emit itemsReady(res_batch);
						res_batch.clear ();
						batch++;
						i = 0;
					}
				}
			}
		}
		emit itemsReady(res_batch);
		emit finished(res);
	}

signals:
	void finished(FMH::MODEL_LIST items);
	void start(QList<QUrl> urls, bool recursive);

	void itemsReady(FMH::MODEL_LIST items);
	void itemReady(FMH::MODEL item);

private:
	QThread t;

};


#endif // FILELOADER_H
