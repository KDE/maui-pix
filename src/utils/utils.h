#ifndef UTILS_H
#define UTILS_H

#include <QObject>

class Utils : public QObject
{
    Q_OBJECT
public:
    explicit Utils(QObject *parent = nullptr);

    Q_INVOKABLE static QString backgroundColor();
    Q_INVOKABLE static QString foregroundColor();
    Q_INVOKABLE static QString hightlightColor();
    Q_INVOKABLE static QString midColor();
    Q_INVOKABLE static QString altColor();



};

#endif // UTILS_H
