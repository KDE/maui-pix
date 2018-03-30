#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include "src/pix.h"

#ifdef Q_OS_ANDROID
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setApplicationName(PIX::App);
    app.setApplicationVersion(PIX::version);
    app.setApplicationDisplayName(PIX::App);
    app.setWindowIcon(QIcon(":/img/assets/pix.png"));

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
    });

    auto context = engine.rootContext();
    context->setContextProperty("pix", &pix);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
