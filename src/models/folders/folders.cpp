#include "models/folders/folders.h"
#include "db/dbactions.h"

Folders::Folders(QObject *parent) : MauiList(parent)
{
    qDebug()<< "CREATING GALLERY LIST";
    this->setList();
}

FMH::MODEL_LIST Folders::items() const
{
    return this->list;
}

void Folders::setList()
{
    emit this->preListChanged();
    this->list = DBActions::getInstance()->getFolders("select * from sources");
    emit this->postListChanged();
}

QVariantMap Folders::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();
    return FMH::toMap(this->list.at(this->mappedIndex(index)));
}

void Folders::refresh()
{
    this->setList();
}
