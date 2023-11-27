#pragma once

#include <QObject>

class PixServer : public QObject
{
    Q_OBJECT
public:
    explicit PixServer(QObject *parent = nullptr);

};
