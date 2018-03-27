#include <QApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>
#include <QQuickStyle>
#include "src/pix.h"

#ifdef Q_OS_ANDROID
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/utils/materialdesignicons-webfont.ttf");

#ifdef Q_OS_ANDROID
    KirigamiPlugin::getInstance().registerTypes();
#else
//    if(QQuickStyle::availableStyles().contains("nomad"))
//        QQuickStyle::setStyle("nomad");
#endif

    QQmlApplicationEngine engine;
    auto context = engine.rootContext();

    Pix pix;
    context->setContextProperty("pix", &pix);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
