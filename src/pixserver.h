#pragma once
#include <QObject>

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
class OrgKdePixActionsInterface;

namespace AppInstance
{
QVector<QPair<QSharedPointer<OrgKdePixActionsInterface>, QStringList>> appInstances(const QString& preferredService);

bool attachToExistingInstance(const QPair<QString, QList<QUrl> > &data);

bool registerService();
}
#endif

class Server : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.pix.Actions")

public:
    explicit Server(QObject *parent = nullptr);
    void setQmlObject(QObject  *object);

public Q_SLOTS:
    /**
     * Tries to raise/activate the Dolphin window.
     */
    void activateWindow();

    /** Stores all settings and quits Dolphin. */
    void quit();

    void view(const QStringList &urls);


private:
    QObject* m_qmlObject = nullptr;

};

