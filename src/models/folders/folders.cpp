#include "folders.h"

#include <QDebug>

#include <MauiKit/FileBrowsing/fmstatic.h>

Folders::Folders(QObject *parent)
    : MauiList(parent)
{
    qDebug() << "CREATING GALLERY LIST";
}

const FMH::MODEL_LIST &Folders::items() const
{
    return this->list;
}

void Folders::setFolders(const QList<QUrl> &folders)
{
    if (m_folders == folders)
        return;

    m_folders = folders;

    emit this->preListChanged();
    this->list.clear();

    for (const auto &folder : std::as_const(m_folders)) {
        this->list << FMStatic::getFileInfoModel(folder);
    }
    emit this->postListChanged();
    emit foldersChanged();
}

QList<QUrl> Folders::folders() const
{
    return m_folders;
}

QVariantMap Folders::get(const int &index) const
{
    if (index >= this->list.size() || index < 0)
        return QVariantMap();
    return FMH::toMap(this->list.at(this->mappedIndex(index)));
}

void Folders::refresh()
{
    this->setFolders(m_folders);
}
