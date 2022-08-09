#include "folders.h"

#include <QDebug>

#include <MauiKit/FileBrowsing/fmstatic.h>

Folders::Folders(QObject *parent)
    : MauiList(parent)
{}

const FMH::MODEL_LIST &Folders::items() const
{
    return this->list;
}

void Folders::setFolders(const QList<QUrl> &folders)
{
    if (m_folders == folders)
        return;

    m_folders = folders;
    emit this->foldersChanged();
}

QList<QUrl> Folders::folders() const
{
    return m_folders;
}

void Folders::refresh()
{
    this->setFolders(m_folders);
}

void Folders::componentComplete()
{
    connect (this, &Folders::foldersChanged, this, &Folders::setList);
    setList();
}

void Folders::setList()
{
    emit this->preListChanged();
    this->list.clear();

    for (const auto &folder : (m_folders))
    {
        this->list << FMStatic::getFileInfoModel(folder);
    }

    emit this->postListChanged();
    emit this->countChanged();
}


