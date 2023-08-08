#include "folders.h"

#include <QDebug>
#include <QDir>
#include <QDirIterator>

#include <MauiKit3/FileBrowsing/fmstatic.h>

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
        auto item = FMStatic::getFileInfoModel(folder);
        item[FMH::MODEL_KEY::PREVIEW] = getPreviews(item[FMH::MODEL_KEY::PATH]).join(",");
        this->list << item;
    }

    emit this->postListChanged();
    emit this->countChanged();
}

QStringList Folders::getPreviews(const QString &path)
{
    QStringList res;
    QDir dir(QUrl::fromUserInput(path).toLocalFile());

    qDebug() << "GET PREVIEWS" << path << QUrl::fromUserInput(path).toLocalFile();

    if(!dir.exists())
        return res;

    dir.setFilter(QDir::Files);
    dir.setSorting(QDir::Time);
    dir.setNameFilters(FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::IMAGE]);

    int i= 0;

    for(const auto &entry : dir.entryInfoList())
    {
        if(i >= 4)
            break;

        res << QUrl::fromLocalFile(entry.filePath()).toString();
        i++;
    }

    qDebug() << "GET PREVIEWS" << res;

    return res;
}


