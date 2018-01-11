#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
//#ifdef Q_OS_ANDROID
//#include "./3rdparty/kirigami/src/kirigamiplugin.h"
//#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/utils/materialdesignicons-webfont.ttf");

//    #ifdef Q_OS_ANDROID
//        KirigamiPlugin::getInstance().registerTypes();
//    #endif

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
