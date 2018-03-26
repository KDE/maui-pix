#ifndef NOTIFY_H
#define NOTIFY_H

#include <QObject>
#include <QByteArray>

#include <klocalizedstring.h>
#include <knotifyconfig.h>
#include <knotification.h>

#include <QStandardPaths>
#include <QPixmap>
#include <QDebug>
#include <QMap>
#include "../src/utils/pic.h"

class Notify : public QObject
{
    Q_OBJECT

public:
    explicit Notify(QObject *parent = nullptr);
    ~Notify();
    void notify(const QString &title, const QString &body);

private:

};

#endif // NOTIFY_H
