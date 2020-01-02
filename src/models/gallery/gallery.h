#ifndef GALLERY_H
#define GALLERY_H

#include <QObject>

#include "utils/pic.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class DBActions;
class Gallery : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged())

public:
    explicit Gallery(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const override final;

    void setQuery(const QString &query);
    QString getQuery() const;

private:
    DBActions *dba;
    FMH::MODEL_LIST list;
    void setList();

    QString query;

signals:
    void queryChanged();

public slots:    
    QVariantMap get(const int &index) const;
    bool update(const int &index, const QVariant &value, const int &role); //deprecrated
    bool update(const QVariantMap &data, const int &index);
    bool update(const FMH::MODEL &pic);
    bool remove(const int &index);
    bool deleteAt(const int &index);
    void append(const QVariantMap &pic);
    void append(const QString &url);
//    void appendAt(const QString &url, const int &pos);
    void refresh();
    void clear();
};

#endif // GALLERY_H
