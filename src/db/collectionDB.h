#ifndef COLLECTIONDB_H
#define COLLECTIONDB_H
#include <QString>
#include <QStringList>
#include <QList>
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSqlDriver>
#include <QFileInfo>
#include <QDir>
#include <QVariantMap>

#include "../utils/pix.h"

enum sourceTypes
{
    LOCAL, ONLINE, DEVICE
};

class CollectionDB : public QObject
{
    Q_OBJECT

public:
    explicit CollectionDB(QObject *parent = nullptr);
    ~CollectionDB() override;
    void openDB(const QString &name);

    /*basic public actions*/
    void prepareCollectionDB() const;
    bool check_existance(const QString &tableName, const QString &searchId, const QString &search);

    /* usefull actions */
    void addPic(const PIX::DB &img);
    /*useful tools*/

    PIX::DB_LIST getDBData(const QString &queryTxt);
    QVariantList getDBDataQML(const QString &queryTxt);

    bool execQuery(const QString &queryTxt);

    QSqlQuery getQuery(const QString &queryTxt);

private:
    QString name;
    QSqlDatabase m_db;
    /*basic actions*/
    bool insert(const QString &tableName, const QVariantMap &insertData);
    bool update(const QString &tableName, const PIX::DB &updateData, const QVariantMap &where);
    bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
    bool remove();

public slots:
    void closeConnection();

signals:
    void imgInserted();
};

#endif // COLLECTION_H
