#include "pixserver.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <QQmlApplicationEngine>

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
#include "pixinterface.h"
#include "pixadaptor.h"

QVector<QPair<QSharedPointer<OrgKdePixActionsInterface>, QStringList>> AppInstance::appInstances(const QString& preferredService)
{
    QVector<QPair<QSharedPointer<OrgKdePixActionsInterface>, QStringList>> dolphinInterfaces;

    if (!preferredService.isEmpty())
    {
        QSharedPointer<OrgKdePixActionsInterface> preferredInterface(
            new OrgKdePixActionsInterface(preferredService,
                                           QStringLiteral("/Actions"),
                                           QDBusConnection::sessionBus()));

        qDebug() << "IS PREFRFRED INTERFACE VALID?" << preferredInterface->isValid() << preferredInterface->lastError().message();
        if (preferredInterface->isValid() && !preferredInterface->lastError().isValid()) {
            dolphinInterfaces.append(qMakePair(preferredInterface, QStringList()));
        }
    }

           // Look for dolphin instances among all available dbus services.
    QDBusConnectionInterface *sessionInterface = QDBusConnection::sessionBus().interface();
    const QStringList dbusServices = sessionInterface ? sessionInterface->registeredServiceNames().value() : QStringList();
    // Don't match the service without trailing "-" (unique instance)
    const QString pattern = QStringLiteral("org.kde.pix-");

           // Don't match the pid without leading "-"
    const QString myPid = QLatin1Char('-') + QString::number(QCoreApplication::applicationPid());

    for (const QString& service : dbusServices)
    {
        if (service.startsWith(pattern) && !service.endsWith(myPid))
        {
            qDebug() << "EXISTING INTANCES" << service;

                   // Check if instance can handle our URLs
            QSharedPointer<OrgKdePixActionsInterface> interface(
                new OrgKdePixActionsInterface(service,
                                               QStringLiteral("/Actions"),
                                               QDBusConnection::sessionBus()));

            if (interface->isValid() && !interface->lastError().isValid())
            {
                dolphinInterfaces.append(qMakePair(interface, QStringList()));
            }
        }
    }

    return dolphinInterfaces;
}

bool AppInstance::attachToExistingInstance(const QPair<QString, QList<QUrl>> &data, bool windowed)
{
    bool attached = false;

    auto dolphinInterfaces = appInstances("");
    if (dolphinInterfaces.isEmpty())
    {
        return attached;
    }

    for (const auto& interface: std::as_const(dolphinInterfaces))
    {
        if(data.first == "viewer" && !data.second.isEmpty())
        {
            auto reply = interface.first->view(QUrl::toStringList(data.second), windowed);
            reply.waitForFinished();

            if (!reply.isError())
            {
                interface.first->activateWindow();
                attached = true;
                break;
            }
        }else if(data.first =="folder" && !data.second.isEmpty())
        {
            auto reply = interface.first->openFolder(data.second.first().toString());
            reply.waitForFinished();

            if (!reply.isError())
            {
                interface.first->activateWindow();
                attached = true;
                break;
            }
        }else if(data.first =="editor" && !data.second.isEmpty())
        {
            auto reply = interface.first->openEditor(data.second.first().toString(), windowed);
            reply.waitForFinished();

            if (!reply.isError())
            {
                interface.first->activateWindow();
                attached = true;
                break;
            }
        }else
        {
            auto reply = interface.first->activateWindow();
            reply.waitForFinished();

            if (!reply.isError())
            {
                attached = true;
                break;
            }
        }
    }

    return attached;
}

bool AppInstance::registerService()
{
    QDBusConnectionInterface *iface = QDBusConnection::sessionBus().interface();

    auto registration = iface->registerService(QStringLiteral("org.kde.pix-%1").arg(QCoreApplication::applicationPid()),
                                               QDBusConnectionInterface::ReplaceExistingService,
                                               QDBusConnectionInterface::DontAllowReplacement);

    if (!registration.isValid())
    {
        qWarning("2 Failed to register D-Bus service \"%s\" on session bus: \"%s\"",
                 qPrintable("org.kde.pix"),
                 qPrintable(registration.error().message()));
        return false;
    }

    return true;
}

#endif



Server::Server(QObject *parent) : QObject(parent)
    , m_qmlObject(nullptr)
{
#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
    new ActionsAdaptor(this);
    if(!QDBusConnection::sessionBus().registerObject(QStringLiteral("/Actions"), this))
    {
        qDebug() << "FAILED TO REGISTER BACKGROUND DBUS OBJECT";
        return;
    }
#endif
}

void Server::setQmlObject(QObject *object)
{
    if(!m_qmlObject)
    {
        m_qmlObject = object;
    }
}

void Server::activateWindow()
{
    if(m_qmlObject)
    {
        qDebug() << "ACTIVET WINDOW FROM C++";
        auto window = qobject_cast<QQuickWindow *>(m_qmlObject);
        if (window)
        {
            qDebug() << "Trying to raise wndow";
            window->raise();
            window->requestActivate();
        }
    }
}

void Server::quit()
{
    QCoreApplication::quit();
}

void Server::view(const QStringList &urls, bool windowed)
{
    if(m_qmlObject)
    {
        QMetaObject::invokeMethod(m_qmlObject, "view",
                                  Q_ARG(QVariant, urls), Q_ARG(bool, windowed));
    }
}

void Server::openFolder(const QString &url)
{
    if(m_qmlObject)
    {
        QMetaObject::invokeMethod(m_qmlObject, "openFolder",
                                  Q_ARG(QString, url), Q_ARG(QVariant, ""));
    }
}

void Server::openEditor(const QString &url, bool windowed)
{
    if(m_qmlObject)
    {
        QMetaObject::invokeMethod(m_qmlObject, "openEditorWindow",
                                  Q_ARG(QString, url), Q_ARG(bool, windowed));
    }
}
