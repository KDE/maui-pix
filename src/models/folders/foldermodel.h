#ifndef FOLDERMODEL_H
#define FOLDERMODEL_H

#include <QAbstractListModel>
#include <QList>

class Folders;
class FolderModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Folders *list READ getList WRITE setList)

public:
    explicit FolderModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    Folders* getList() const;
    void setList(Folders *value);

private:
    Folders *mList;
signals:
    void listChanged();
};

#endif // NOTESMODEL_H
