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

#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QQmlContext>
#include <QIcon>
#include <QFileInfo>
#include "pix.h"

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#include "fmh.h"
#include "tagging.h"
#include "mauiapp.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/tagging.h>
#include <MauiKit/mauiapp.h>
#endif

#include "models/gallery/gallery.h"
//#include "models/cloud/cloud.h"
#include "models/folders/folders.h"
#include "models/picinfomodel.h"

#ifdef Q_OS_MACOS
#include "mauimacos.h"
#endif

#include <KI18n/KLocalizedContext>

static const  QList<QUrl>  getFolderImages(const QString &path)
{
	QList<QUrl> urls;

	if (QFileInfo(path).isDir())
	{
		QDirIterator it(path, FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], QDir::Files, QDirIterator::Subdirectories);
		while (it.hasNext())
			urls << QUrl::fromLocalFile(it.next());

	}else if (QFileInfo(path).isFile())
		urls << path;

	return urls;
}

static const QList<QUrl> openFiles(const QStringList &files)
{
	QList<QUrl>  urls;

	if(files.size()>1)
	{
		for(const auto &file : files)
			urls << QUrl::fromUserInput(file);
	}
	else if(files.size() == 1)
	{
		auto folder = QFileInfo(files.first()).dir().absolutePath();
		urls = getFolderImages(folder);
		urls.removeOne(QUrl::fromLocalFile(files.first()));
		urls.insert(0,QUrl::fromLocalFile(files.first()));
	}

	return urls;
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
	QGuiApplication app(argc, argv);
	if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
		return -1;
#else
	QApplication app(argc, argv);
#endif

	app.setApplicationName(PIX::appName);
	app.setApplicationVersion(PIX::version);
	app.setApplicationDisplayName(PIX::displayName);
	app.setOrganizationName(PIX::orgName);
	app.setOrganizationDomain(PIX::orgDomain);
    app.setWindowIcon(QIcon(":/img/assets/pix.png"));
    MauiApp::instance()->setHandleAccounts(false); //for now index can not handle cloud accounts
    MauiApp::instance()->setCredits ({QVariantMap({{"name", "Camilo Higuita"}, {"email", "milo.h@aol.com"}, {"year", "2019-2020"}})});
    MauiApp::instance()->setDescription("Pix organizes and manages your images gallery collection");
    MauiApp::instance()->setIconName("qrc:/assets/pix.svg");
    MauiApp::instance()->setHandleAccounts(false);
    MauiApp::instance()->setWebPage("https://mauikit.org");
    MauiApp::instance()->setReportPage("https://invent.kde.org/maui/index-fm/-/issues");

	QCommandLineParser parser;
	parser.setApplicationDescription(PIX::description);
	const QCommandLineOption versionOption = parser.addVersionOption();
	parser.addOption(versionOption);
	parser.process(app);

	const QStringList args = parser.positionalArguments();

	QList<QUrl> pics;
	if(!args.isEmpty())
		pics = openFiles(args);

	static auto pix = new Pix;

	QQmlApplicationEngine engine;
	QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, [&]()
	{
		if(!pics.isEmpty())
			pix->openPics(pics);
	});

	qmlRegisterSingletonType<Pix>("org.maui.pix", 1, 0, "Collection",
								  [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
		Q_UNUSED(scriptEngine)
        engine->setObjectOwnership(pix, QQmlEngine::CppOwnership);
		return pix;
	});

	qmlRegisterType<Gallery>("GalleryList", 1, 0, "GalleryList");
    qmlRegisterType<Folders>("FoldersList", 1, 0, "FoldersList");
    qmlRegisterType<PicInfoModel>("org.maui.pix", 1, 0, "PicInfoModel");

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

#ifdef STATIC_KIRIGAMI
	KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
	MauiKit::getInstance().registerTypes();
#endif

	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

#ifdef Q_OS_MACOS
//    MAUIMacOS::removeTitlebarFromWindow();
//    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif

	return app.exec();
}
