#include "foldermodel.h"
#include "folders.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

FolderModel::FolderModel(QObject *parent)
    : QAbstractListModel(parent),
      mList(nullptr)
{}

int FolderModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !mList)
        return 0;

    return mList->items().size();
}

QVariant FolderModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mList)
        return QVariant();

    return mList->items().at(index.row())[static_cast<FMH::MODEL_KEY>(role)];
}

bool FolderModel::setData(const QModelIndex &index, const QVariant &value, int role)
{

    return false;
}

Qt::ItemFlags FolderModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> FolderModel::roleNames() const
{
    QHash<int, QByteArray> names;

        for(auto key : FMH::MODEL_NAME.keys())
            names[key] = QString(FMH::MODEL_NAME[key]).toUtf8();

        return names;
}

Folders *FolderModel::getList() const
{
    return this->mList;
}

void FolderModel::setList(Folders *value)
{
    beginResetModel();

    if(mList)
        mList->disconnect(this);

    mList = value;

    if(mList)
    {
        connect(this->mList, &Folders::preItemAppended, this, [=]()
        {
            const int index = mList->items().size();
            beginInsertRows(QModelIndex(), index, index);
        });

        connect(this->mList, &Folders::postItemAppended, this, [=]()
        {
            endInsertRows();
        });

        connect(this->mList, &Folders::preItemRemoved, this, [=](int index)
        {
            beginRemoveRows(QModelIndex(), index, index);
        });

        connect(this->mList, &Folders::postItemRemoved, this, [=]()
        {
            endRemoveRows();
        });

        connect(this->mList, &Folders::updateModel, this, [=](int index, QVector<int> roles)
        {
            emit this->dataChanged(this->index(index), this->index(index), roles);
        });

        connect(this->mList, &Folders::preListChanged, this, [=]()
        {
            beginResetModel();
        });

        connect(this->mList, &Folders::postListChanged, this, [=]()
        {
            endResetModel();
        });
    }

    endResetModel();
}
