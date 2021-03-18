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

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QQuickStyle>
#else
#include <QApplication>
#endif

#include "../pix_version.h"
#include <MauiKit/fmh.h>
#include <MauiKit/mauiapp.h>

#ifdef Q_OS_MACOS
#include "mauimacos.h"
#endif

#if defined Q_OS_MACOS || defined Q_OS_WIN
#include <KF5/KI18n/KLocalizedString>
#else
#include <KI18n/KLocalizedString>
#endif

#include "models/folders/folders.h"
#include "models/gallery/gallery.h"
#include "models/picinfomodel.h"
#include "models/tags/tagsmodel.h"
#include "pix.h"

#define PIX_URI "org.maui.pix"

static const QList<QUrl> getFolderImages(const QString &path)
{
    QList<QUrl> urls;

    if (QFileInfo(path).isDir()) {
        QDirIterator it(path, FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], QDir::Files, QDirIterator::NoIteratorFlags);
        while (it.hasNext())
            urls << QUrl::fromLocalFile(it.next());

    } else if (QFileInfo(path).isFile())
        urls << path;

    return urls;
}

static const QList<QUrl> openFiles(const QStringList &files)
{
    QList<QUrl> urls;

    if (files.size() > 1) {
        for (const auto &file : files)
            urls << QUrl::fromUserInput(file);
    } else if (files.size() == 1) {
        auto folder = QFileInfo(files.first()).dir().absolutePath();
        urls = getFolderImages(folder);
        urls.removeOne(QUrl::fromLocalFile(files.first()));
        urls.insert(0, QUrl::fromLocalFile(files.first()));
    }

    return urls;
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("maui-style");

    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/img/assets/pix.png"));

    MauiApp::instance()->setHandleAccounts(false); // for now pix can not handle cloud accounts
    MauiApp::instance()->setIconName("qrc:/assets/pix.svg");

    KLocalizedString::setApplicationDomain("pix");
    KAboutData about(QStringLiteral("pix"), i18n("Pix"), PIX_VERSION_STRING, i18n("Pix lets you organize, browse, and edit your image collection."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/pix");
    about.setBugAddress("https://invent.kde.org/maui/pix/-/issues");
    about.setOrganizationDomain(PIX_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);

    const QStringList args = parser.positionalArguments();

    QList<QUrl> pics;
    if (!args.isEmpty())
        pics = openFiles(args);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, [&]() {
        if (!pics.isEmpty())
            Pix::instance()->openPics(pics);
    });

    qmlRegisterSingletonInstance<Pix>(PIX_URI, 1, 0, "Collection", Pix::instance());

    qmlRegisterType<Gallery>(PIX_URI, 1, 0, "GalleryList");
    qmlRegisterType<Folders>(PIX_URI, 1, 0, "FoldersList");
    qmlRegisterType<TagsModel>(PIX_URI, 1, 0, "TagsList");
    qmlRegisterType<PicInfoModel>(PIX_URI, 1, 0, "PicInfoModel");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

#ifdef Q_OS_MACOS
//    MAUIMacOS::removeTitlebarFromWindow();
//    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif

    return app.exec();
}
