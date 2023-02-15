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

#include <QCommandLineParser>
#include <QFileInfo>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDirIterator>
#include <QPair>
#include <QDate>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include "../pix_version.h"

#include <MauiKit/Core/mauiapp.h>
#include <MauiKit/FileBrowsing/fmstatic.h>

#ifdef Q_OS_MACOS
#include <MauiKit/Core/mauimacos.h>
#endif

#include <KI18n/KLocalizedString>

#include "models/folders/folders.h"
#include "models/folders/placesmodel.h"
#include "models/gallery/gallery.h"
#include "models/tags/tagsmodel.h"
#include "models/cities/citiesmodel.h"

#include "pix.h"

#define PIX_URI "org.maui.pix"

//static const QList<QUrl> getFolderImages(const QString &path)
//{
//    QList<QUrl> urls;

//    if (QFileInfo(path).isDir()) {
//        QDirIterator it(path, FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::IMAGE], QDir::Files, QDirIterator::NoIteratorFlags);
//        while (it.hasNext())
//            urls << QUrl::fromLocalFile(it.next());

//    } else if (QFileInfo(path).isFile())
//        urls << path;

//    return urls;
//}

static const QPair<QString, QList<QUrl>> openFiles(const QStringList &files)
{
    QList<QUrl> urls;
    QString module;

    if (files.size() > 1)
    {
        module = "viewer";
        for (const auto &file : files)
        {
            if(FMStatic::isDir(QUrl::fromUserInput(file)))
                continue;

            urls << QUrl::fromUserInput(file);
        }
    } else if (files.size() == 1)
    {
        if(FMStatic::isDir(QUrl::fromUserInput(files.first())))
        {
            module = "folder";
            urls << QUrl::fromUserInput(files.first());
        }else
        {
            module = "viewer";
            //            auto folder = QFileInfo(files.first()).dir().absolutePath();
            //            urls = getFolderImages(folder);
            //            urls.removeOne(QUrl::fromLocalFile(files.first()));
            urls.insert(0, QUrl::fromLocalFile(files.first()));
        }
    }

    return {module, urls};
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/assets/pix.png"));

    KLocalizedString::setApplicationDomain("pix");

    KAboutData about(QStringLiteral("pix"), i18n("Pix"), PIX_VERSION_STRING, i18n("Organize, browse, and edit your images."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Maui Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/pix");
    about.setBugAddress("https://invent.kde.org/maui/pix/-/issues");
    about.setOrganizationDomain(PIX_URI);
    about.setProgramLogo(app.windowIcon());
    about.addComponent("Exiv2");

    KAboutData::setApplicationData(about);
    MauiApp::instance()->setIconName("qrc:/assets/pix.png");

    QCommandLineParser parser;

    about.setupCommandLine(&parser);
    parser.process(app);

    about.processCommandLine(&parser);
    const QStringList args = parser.positionalArguments();

    QPair<QString, QList<QUrl>> arguments;
    arguments.first = "folder";

    if (!args.isEmpty())
    {
        arguments = openFiles(args);
    }

//    QScopedPointer<ScreenshotInhibit> screenshot(new ScreenshotInhibit(qApp->desktopFileName()));
//    screenshot->blacklist();

    QQmlApplicationEngine engine;
    QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
                &engine,
                &QQmlApplicationEngine::objectCreated,
                &app,
                [url, arguments](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        auto module = arguments.first;
        auto data = arguments.second;

        if (!data.isEmpty() )
        {
            if(module == "viewer")
            {
                Pix::instance()->openPics(data);
            }else if(module == " folder")
            {

            }
        }
    },
    Qt::QueuedConnection);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.rootContext()->setContextProperty("initModule", arguments.first);
    engine.rootContext()->setContextProperty("initData", QUrl::toStringList(arguments.second));

    qmlRegisterSingletonInstance<Pix>(PIX_URI, 1, 0, "Collection", Pix::instance());

    qmlRegisterType<Gallery>(PIX_URI, 1, 0, "GalleryList");
    qmlRegisterType<PlacesModel>(PIX_URI, 1, 0, "PlacesList");
    qmlRegisterType<Folders>(PIX_URI, 1, 0, "FoldersList");
    qmlRegisterType<CitiesModel>(PIX_URI, 1, 0, "CitiesList");
    qmlRegisterType<TagsModel>(PIX_URI, 1, 0, "TagsList");

    engine.load(url);

#ifdef Q_OS_MACOS
    //    MAUIMacOS::removeTitlebarFromWindow();
    //    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif

    return app.exec();
}
