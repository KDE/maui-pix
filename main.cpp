#include <QApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>

#include "src/utils/pix.h"
#include "src/utils/utils.h"

//#ifdef Q_OS_ANDROID
//#include "./3rdparty/kirigami/src/kirigamiplugin.h"
//#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/utils/materialdesignicons-webfont.ttf");

    //    #ifdef Q_OS_ANDROID
    //        KirigamiPlugin::getInstance().registerTypes();
    //    #endif

    QQmlApplicationEngine engine;
    auto context = engine.rootContext();

    Pix pix;
    context->setContextProperty("PIX", &pix);
    Utils util;
    context->setContextProperty("UTI", &util);


    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
