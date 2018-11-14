#ifndef GALLERY_H
#define GALLERY_H

#include <QObject>
#include "./src/models/baselist.h"
#include "./src/utils/pic.h"

class DBActions;
class Gallery : public BaseList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(uint sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:
    explicit Gallery(QObject *parent = nullptr);
    PIX::DB_LIST items() const override;

    void setQuery(const QString &query);
    QString getQuery() const;

    void setSortBy(const uint &sort);
    uint getSortBy() const;

private:
    DBActions *dba;
    PIX::DB_LIST list;
    void sortList();
    void setList();

    QString query;
    uint sort = PIX::KEY::ADD_DATE;

    bool addPic(const PIX::DB &img);

signals:
    void queryChanged();
    void orderChanged();
    void sortByChanged();

public slots:    
    QVariantMap get(const int &index) const override;
    bool update(const int &index, const QVariant &value, const int &role) override; //deprecrated
    bool update(const QVariantMap &data, const int &index) override;
    bool update(const PIX::DB &pic) override;
    bool remove(const int &index) override;
    void append(const QVariantMap &pic);
    void refresh();
};

#endif // GALLERY_H
