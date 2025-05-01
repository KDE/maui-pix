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
#include <QImageReader>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit4/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include "../pix_version.h"

#include <MauiKit4/Core/mauiapp.h>
#include <MauiKit4/FileBrowsing/fmstatic.h>

#include <MauiKit4/ImageTools/moduleinfo.h>

#ifdef Q_OS_MACOS
#include <MauiKit3/Core/mauimacos.h>
#endif

#include <KLocalizedString>

#include "models/folders/folders.h"
#include "models/folders/placesmodel.h"
#include "models/gallery/gallery.h"
#include "models/tags/tagsmodel.h"
#include "models/cities/citiesmodel.h"
#include "pixserver.h"

#include "pix.h"

#define PIX_URI "org.maui.pix"

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
            urls << QUrl::fromLocalFile(files.first());
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
#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    QImageReader::setAllocationLimit(2000);

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/assets/pix.png"));

    KLocalizedString::setApplicationDomain("pix");

    KAboutData about(QStringLiteral("pix"),
                     QStringLiteral("Pix"),
                     PIX_VERSION_STRING,
                     i18n("Organize, browse, and edit your images."),
                     KAboutLicense::LGPL_V3,
                     APP_COPYRIGHT_NOTICE,
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(QStringLiteral("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/pix");
    about.setBugAddress("https://invent.kde.org/maui/pix/-/issues");
    about.setOrganizationDomain(PIX_URI);
    about.setProgramLogo(app.windowIcon());

    const auto exiv2Data = MauiKitImageTools::exiv2Data();
    about.addComponent(exiv2Data.name(), "", exiv2Data.version(), exiv2Data.webAddress());

    const auto kexiv2Data = MauiKitImageTools::libKexiv2Data();
    about.addComponent(kexiv2Data.name(), kexiv2Data.description(), kexiv2Data.version(), kexiv2Data.webAddress());

    const auto ITData = MauiKitImageTools::aboutData();
    about.addComponent(ITData.name(), MauiKitImageTools::buildVersion(), ITData.version(), ITData.webAddress());

    const auto OCRData = MauiKitImageTools::tesseractData();
    about.addComponent(OCRData.name(), OCRData.description(), OCRData.version(), OCRData.webAddress());

    const auto openCVData = MauiKitImageTools::opencvData();
    about.addComponent(openCVData.name(), openCVData.description(), openCVData.version(), openCVData.webAddress());

    KAboutData::setApplicationData(about);
    MauiApp::instance()->setIconName("qrc:/assets/pix.png");

    QCommandLineOption newWindow(QStringList() << "w" << "window", "Open in window.", "windowed", "true");
    QCommandLineOption viewCommand(QStringList() << "o" << "o", "View images or folder", "url1,url2,...");
    QCommandLineOption editCommand(QStringList() << "e" << "edit", "Edit an image", "url");

    QCommandLineParser parser;

    parser.addOption(newWindow);
    parser.addOption(viewCommand);
    parser.addOption(editCommand);

    about.setupCommandLine(&parser);
    parser.process(app);

    about.processCommandLine(&parser);
    const QStringList args = parser.positionalArguments();

    bool windowed = parser.isSet(newWindow);

    QPair<QString, QList<QUrl>> arguments;
    arguments.first = "folder";

    if(parser.isSet(viewCommand))
    {
        arguments = openFiles(parser.values(viewCommand));
    }else if(parser.isSet(editCommand))
    {
        arguments.first = "editor";
        arguments.second = {parser.value(editCommand)};
    }else
    {
        if (!args.isEmpty())
        {
            arguments = openFiles(args);
            qDebug() << args << arguments.first << arguments.second << QUrl::toStringList(arguments.second);
        }
    }

//    QScopedPointer<ScreenshotInhibit> screenshot(new ScreenshotInhibit(qApp->desktopFileName()));
//    screenshot->blacklist();
#ifdef Q_OS_ANDROID
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.MANAGE_EXTERNAL_STORAGE",
                                               "android.permission.WRITE_EXTERNAL_STORAGE"}))
        qWarning() << "Failed to get WRITE and READ permissions";
#endif

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
    if (AppInstance::attachToExistingInstance(arguments, windowed))
    {
        // Successfully attached to existing instance of Nota
        return 0;
    }

    AppInstance::registerService();
#endif

    auto server = std::make_unique<Server>();

    QQmlApplicationEngine engine;
    QUrl url(QStringLiteral("qrc:/app/maui/pix/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url, arguments, &server](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);

            server->setQmlObject(obj);

            auto module = arguments.first;
            auto data = arguments.second;

            if (!data.isEmpty() )
            {
                if(module == "viewer")
                {
                    // Pix::instance()->openPics(data);
                    server->view(QUrl::toStringList(data), false);
                }else if(module == "folder")
                {

                }else if(module == "editor")
                {
                    server->openEditor(data.first().toString(), false);
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
    qmlRegisterType<FileWatcher>(PIX_URI, 1, 0, "FileWatcher");

    engine.load(url);

#ifdef Q_OS_MACOS
    //    MAUIMacOS::removeTitlebarFromWindow();
    //    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif

    return app.exec();
}
