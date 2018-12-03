#ifndef CLOUD_H
#define CLOUD_H

#include <QObject>
#include "./src/models/baselist.h"

class FM;
class Cloud : public BaseList
{
    Q_OBJECT
    Q_PROPERTY(QString account READ getAccount WRITE setAccount NOTIFY accountChanged)

public:   
   explicit Cloud(QObject *parent = nullptr);
//     ~Cloud();
    FMH::MODEL_LIST items() const override;

    void setAccount(const QString value);
    QString getAccount() const;

private:
    FMH::MODEL_LIST list;
    void setList();

    QString account;
    FM *fm;

public slots:
    QVariantMap get(const int &index) const override;

signals:
    void accountChanged();
};

#endif // CLOUD_H
