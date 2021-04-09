#include "gallery.h"
#include <QFileSystemWatcher>

#include <MauiKit/FileBrowsing/fileloader.h>
#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/tagging.h>

static FMH::MODEL picInfo(const QUrl &url)
{
    const QFileInfo info(url.toLocalFile());
    return FMH::MODEL{{FMH::MODEL_KEY::URL, url.toString()},
                      {FMH::MODEL_KEY::TITLE, info.baseName()},
                      {FMH::MODEL_KEY::SIZE, QString::number(info.size())},
                      {FMH::MODEL_KEY::SOURCE, FMStatic::fileDir(url)},
                      {FMH::MODEL_KEY::DATE, info.birthTime().toString(Qt::TextDate)},
                      {FMH::MODEL_KEY::MODIFIED, info.lastModified().toString(Qt::TextDate)},
                      {FMH::MODEL_KEY::FORMAT, info.suffix()}};
}

Gallery::Gallery(QObject *parent)
    : MauiList(parent)
    , m_fileLoader(new FMH::FileLoader())
    , m_watcher(new QFileSystemWatcher(this))
    , m_autoReload(true)
    , m_recursive(true)
{
    qDebug() << "CREATING GALLERY LIST";
    m_fileLoader->informer = &picInfo;
    m_fileLoader->setBatchCount(4000);
    connect(m_fileLoader, &FMH::FileLoader::finished, [this](FMH::MODEL_LIST items) {
        Q_UNUSED(items)
        
        emit this->filesChanged();
    });

    connect(m_fileLoader, &FMH::FileLoader::itemsReady, [this](FMH::MODEL_LIST items) {
        qDebug() << "Items ready" << items.size();

        if (items.isEmpty())
            return;

        emit preItemsAppended(items.size());
        this->list << items;
        emit postItemAppended();
    });

    connect(m_fileLoader, &FMH::FileLoader::itemReady, [this](FMH::MODEL item) {
        this->insertFolder(item[FMH::MODEL_KEY::SOURCE]);
    });

    connect(m_watcher, &QFileSystemWatcher::directoryChanged, [this](QString dir) {
        qDebug() << "Dir changed" << dir;
        this->rescan();
    });
}

Gallery::~Gallery()
{
    delete m_fileLoader;
}

const FMH::MODEL_LIST &Gallery::items() const
{
    return this->list;
}

void Gallery::setUrls(const QList<QUrl> &urls)
{
    qDebug() << "setting urls" << this->m_urls << urls;

    //	if(this->m_urls == urls)
    //		return;

    this->m_urls = urls;
    this->clear();
    emit this->urlsChanged();
}

QList<QUrl> Gallery::urls() const
{
    return m_urls;
}

void Gallery::setAutoReload(const bool &value)
{
    if (m_autoReload == value)
        return;

    m_autoReload = value;
    emit autoReloadChanged();
}

bool Gallery::autoReload() const
{
    return m_autoReload;
}

QList<QUrl> Gallery::folders() const
{
    return m_folders;
}

bool Gallery::recursive() const
{
    return m_recursive;
}

int Gallery::limit() const
{
    return m_limit;
}

QStringList Gallery::files() const
{
    return FMH::modelToList(this->list, FMH::MODEL_KEY::URL);
}

void Gallery::scan(const QList<QUrl> &urls, const bool &recursive, const int &limit)
{
    this->scanTags(extractTags(urls), limit);
    m_fileLoader->requestPath(urls, recursive, FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], QDir::Files, limit);
}

void Gallery::scanTags(const QList<QUrl> &urls, const int &limit)
{
    FMH::MODEL_LIST res;
    for (const auto &tagUrl : urls) {
        const auto urls = Tagging::getInstance()->getTagUrls(tagUrl.toString().replace("tags:///", ""), {}, true, limit, "image");
        for (const auto &url : urls) {
            res << picInfo(url);
        }
    }

    emit this->preListChanged();
    list << res;
    emit this->postListChanged();
    emit countChanged();
}

void Gallery::insertFolder(const QUrl &path)
{
    if (!m_folders.contains(path)) {
        m_folders << path;

        if (m_autoReload) {
            this->m_watcher->addPath(path.toLocalFile());
        }

        emit foldersChanged();
    }
}

QList<QUrl> Gallery::extractTags(const QList<QUrl> &urls)
{
    QList<QUrl> res;
    return std::accumulate(urls.constBegin(), urls.constEnd(), res, [](QList<QUrl> &list, const QUrl &url) {
        if (FMH::getPathType(url) == FMH::PATHTYPE_KEY::TAGS_PATH) {
            list << url;
        }

        return list;
    });
}

QVariantMap Gallery::get(const int &index) const
{
    if (index >= this->list.size() || index < 0)
        return QVariantMap();
    return FMH::toMap(this->list.at(this->mappedIndex(index)));
}

bool Gallery::remove(const int &index)
{
    Q_UNUSED(index)
    return false;
}

bool Gallery::deleteAt(const int &index)
{
    if (index >= this->list.size() || index < 0)
        return false;

    const auto index_ = this->mappedIndex(index);

    emit this->preItemRemoved(index_);
    auto item = this->list.takeAt(index_);
    FMStatic::removeFiles({item[FMH::MODEL_KEY::URL]});
    emit this->postItemRemoved();

    return true;
}

void Gallery::append(const QVariantMap &pic)
{
    emit this->preItemAppended();
    this->list << FMH::toModel(pic);
    emit this->postItemAppended();
}

void Gallery::append(const QString &url)
{
    emit this->preItemAppended();
    this->list << picInfo(QUrl::fromUserInput(url));
    emit this->postItemAppended();
}

void Gallery::clear()
{
    emit this->preListChanged();
    this->list.clear();
    emit this->postListChanged();

    this->m_folders.clear();
    emit foldersChanged();
}

void Gallery::rescan()
{
    this->clear();
    this->reload();
}

void Gallery::reload()
{
    this->scan(m_urls, m_recursive, m_limit);
}

void Gallery::setRecursive(bool recursive)
{
    if (m_recursive == recursive)
        return;

    m_recursive = recursive;
    emit recursiveChanged(m_recursive);
}

void Gallery::setlimit(int limit)
{
    if (m_limit == limit)
        return;

    m_limit = limit;
    emit limitChanged(m_limit);
}

int Gallery::indexOfName(const QString &query)
{
    const auto it = std::find_if(this->items().constBegin(), this->items().constEnd(), [&](const FMH::MODEL &item) -> bool {
            return item[FMH::MODEL_KEY::TITLE].startsWith(query, Qt::CaseInsensitive);
        });

        if (it != this->items().constEnd())
            return this->mappedIndexFromSource(std::distance(this->items().constBegin(), it));
        else
            return -1;
}

void Gallery::componentComplete()
{
    connect(this, &Gallery::urlsChanged, this, &Gallery::rescan);
    this->reload();
}
