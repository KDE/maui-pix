#ifndef PIXSERVER_H
#define PIXSERVER_H

#include <QObject>

class PixServer : public QObject
{
    Q_OBJECT
public:
    explicit PixServer(QObject *parent = nullptr);

signals:

};

#endif // PIXSERVER_H
