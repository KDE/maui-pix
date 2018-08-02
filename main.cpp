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
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QCommandLineParser>
#include <QFileInfo>
#include "src/pix.h"

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QIcon>
#else
#include <QApplication>
#endif

#ifdef STATIC_KIRIGAMI
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#include "mauikit/src/mauikit.h"

QStringList getFolderImages(const QString &path)
{
    QStringList urls;

    if (QFileInfo(path).isDir())
    {
        QDirIterator it(path, PIX::formats, QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext()) urls<<it.next();

    } else if (QFileInfo(path).isFile()) urls<<path;

    return urls;
}

QStringList openFiles(const QStringList &files)
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

    qDebug()<<"TRYING TO OPEN FILES<<" << urls;

    return urls;
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    app.setApplicationName(PIX::App);
    app.setApplicationVersion(PIX::version);
    app.setApplicationDisplayName(PIX::App);
    app.setWindowIcon(QIcon(":/img/assets/pix.png"));

    QCommandLineParser parser;
    parser.setApplicationDescription("Pix Image gallery viewer");
    const QCommandLineOption versionOption = parser.addVersionOption();
    parser.addOption(versionOption);
    parser.process(app);

    const QStringList args = parser.positionalArguments();

    QStringList pics;

    if(!args.isEmpty())
        pics = openFiles(args);

    Pix pix;

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, [&]()
    {
        qDebug()<<"FINISHED LOADING QML APP";
        pix.refreshCollection();
        if(!pics.isEmpty())
            pix.openPics(pics);
    });

    auto context = engine.rootContext();
    context->setContextProperty("pix", &pix);
    context->setContextProperty("tag", pix.tag);

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef Q_OS_ANDROID
    QIcon::setThemeName("Luv");
#endif

#ifdef MAUI_APP
    MauiKit::getInstance().registerTypes();
#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
