#ifndef ALBUMS_H
#define ALBUMS_H

#include <QObject>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class DBActions;
class Albums : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(FMH::MODEL_KEY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:    
    explicit Albums(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const override final;

    void setQuery(const QString &query);
    QString getQuery() const;

    void setSortBy(const FMH::MODEL_KEY &sort);
    FMH::MODEL_KEY getSortBy() const;

private:
    DBActions *dba;
    FMH::MODEL_LIST list;
    void sortList();
    void setList();

    QString query;
    FMH::MODEL_KEY sort = FMH::MODEL_KEY::ADDDATE;

protected:

signals:
    void queryChanged();
    void orderChanged();
    void sortByChanged();

public slots:
    QVariantMap get(const int &index) const;
    bool insert(const QVariantMap &pic);
    bool update(const int &index, const QVariant &value, const int &role); //deprecrated
    bool update(const QVariantMap &data, const int &index);
    bool update(const FMH::MODEL &pic);
    bool remove(const int &index);
    void insertPic(const QString &album, const QString &url);
};

#endif // ALBUMS_H
