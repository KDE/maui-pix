#ifndef KDE_H
#define KDE_H

#include <QObject>
#include <QVariantList>
#include <KFileItem>

class KDE : public QObject
{
        Q_OBJECT
    public:
        explicit KDE(QObject *parent = nullptr);
        static QVariantList mimeApps(const QUrl &url);
    signals:

    public slots:
};

#endif // KDE_H
