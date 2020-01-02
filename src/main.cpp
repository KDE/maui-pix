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
#include <QIcon>
#include <QCommandLineParser>
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
#else
#include <MauiKit/fmh.h>
#include <MauiKit/tagging.h>
#endif

#include "models/gallery/gallery.h"
//#include "models/cloud/cloud.h"
#include "models/folders/folders.h"


static const QStringList getFolderImages(const QString &path)
{
    QStringList urls;

    if (QFileInfo(path).isDir())
    {
        QDirIterator it(path, FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext())
            urls << it.next();

    }else if (QFileInfo(path).isFile())
        urls << path;

    return urls;
}

static const QStringList openFiles(const QStringList &files)
{
    QStringList urls;

    if(files.size()>1)
        urls = files;
    else
    {
        auto folder = QFileInfo(files.first()).dir().absolutePath();
        urls = getFolderImages(folder);
        urls.removeOne(QString(files.first()));
        urls.insert(0, QString(files.first()));
    }

    return urls;
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions())
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

    QCommandLineParser parser;
    parser.setApplicationDescription(PIX::description);
    const QCommandLineOption versionOption = parser.addVersionOption();
    parser.addOption(versionOption);
    parser.process(app);

    const QStringList args = parser.positionalArguments();

    QStringList pics;

    if(!args.isEmpty())
        pics = openFiles(args);

    static Pix pix;

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, [&]()
    {
        if(!pics.isEmpty())
            pix.openPics(pics);
    });

    qmlRegisterSingletonType<Pix>("org.maui.pix", 1, 0, "Collection",
                                          [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return &pix;
    });

    qmlRegisterSingletonType<DBActions>("org.maui.pix", 1, 0, "DB",
                                          [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return DBActions::getInstance();
    });

    qmlRegisterSingletonType<Tagging>("org.maui.pix", 1, 0, "Tag",
                                          [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return Tagging::getInstance();
    });

    qmlRegisterType<Gallery>("GalleryList", 1, 0, "GalleryList");
    qmlRegisterType<Folders>("FoldersList", 1, 0, "FoldersList");

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes();
#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
