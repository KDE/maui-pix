#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QCommandLineParser>
#include <QFileInfo>
#include "src/pix.h"

#ifdef Q_OS_ANDROID
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
#endif

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

    return urls;
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
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


#ifdef Q_OS_ANDROID
    KirigamiPlugin::getInstance().registerTypes();
    //#else
    //    if(QQuickStyle::availableStyles().contains("nomad"))
    //        QQuickStyle::setStyle("nomad");
#endif

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

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
