#ifndef FOLDERS_H
#define FOLDERS_H

#include <QObject>
#include "./src/utils/pic.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

class DBActions;
class Folders : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(uint sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:    
    explicit Folders(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const;

    void setQuery(const QString &query);
    QString getQuery() const;

    void setSortBy(const uint &sort);
    uint getSortBy() const;

private:
    DBActions *dba;
    FMH::MODEL_LIST list;
    void sortList();
    void setList();

    QString query;
    uint sort = FMH::MODIFIED;

protected:

signals:
    void queryChanged();
    void orderChanged();
    void sortByChanged();

    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void updateModel(int index, QVector<int> roles);
    void preListChanged();
    void postListChanged();

public slots:    
    QVariantMap get(const int &index) const;
    void refresh();

};

#endif // ALBUMS_H
