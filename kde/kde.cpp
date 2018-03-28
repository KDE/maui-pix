#include "kde.h"
#include <KService>
#include <KMimeTypeTrader>
#include <KLocalizedString>
#include <QDebug>
#include <KRun>

KDE::KDE(QObject *parent) : QObject(parent)
{



}

static QVariantMap createActionItem(const QString &label, const QString &actionId, const QVariant &argument = QVariant())
{
    QVariantMap map;

    map["serviceLabel"] = label;
    map["actionId"] = actionId;

    if (argument.isValid()) {
        map["actionArgument"] = argument;
    }

    return map;
}

QVariantList KDE::mimeApps(const QUrl &url)
{
    qDebug()<<"trying to get mimes";
    QVariantList list;

    if (url.isValid())
    {
        auto fileItem = new KFileItem(url);
        fileItem->determineMimeType();

        KService::List services = KMimeTypeTrader::self()->query(fileItem->mimetype(), "Application");

        if (!services.isEmpty())
        {
            foreach (const KService::Ptr service, services)
            {
                const QString text = service->name().replace('&', "&&");
                QVariantMap item = createActionItem(text, "_kicker_fileItem_openWith", service->entryPath());
                item["serviceIcon"] = service->icon();
                item["serviceExec"] = service->exec();

                list << item;
            }
        }

        list << createActionItem(i18n("Properties"), "_kicker_fileItem_properties");

        return list;
    } else return list;
}

void KDE::openWithApp(const QString &exec, const QString &url)
{
    KService service(exec);
    KRun::runApplication(service,{url}, nullptr);
}
