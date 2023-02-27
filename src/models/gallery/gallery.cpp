#include "gallery.h"
#include <QFileSystemWatcher>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QTimer>

#include <KI18n/KLocalizedString>

#include <MauiKit/FileBrowsing/fileloader.h>
#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/tagging.h>
#include <MauiKit/ImageTools/exiv2extractor.h>
#include <MauiKit/ImageTools/textscanner.h>

static QHash<QString, QString> TextInImages;

static FMH::MODEL picInfo(const QUrl &url)
{
    const QFileInfo info(url.toLocalFile());
    return FMH::MODEL{{FMH::MODEL_KEY::URL, url.toString()},
        {FMH::MODEL_KEY::TITLE, info.fileName()},
        {FMH::MODEL_KEY::SIZE, QString::number(info.size())},
        {FMH::MODEL_KEY::SOURCE, QUrl::fromLocalFile(info.absoluteDir().absolutePath()).toString ()},
        {FMH::MODEL_KEY::DATE, info.birthTime().toString(Qt::TextDate)},
        {FMH::MODEL_KEY::MODIFIED, info.lastModified().toString(Qt::TextDate)},
        {FMH::MODEL_KEY::FORMAT, info.completeSuffix()}};
}

static FMH::MODEL picInfo2(const QUrl &url)
{
    const QFileInfo info(url.toLocalFile());
    const Exiv2Extractor exiv2(url);

    return FMH::MODEL{{FMH::MODEL_KEY::URL, url.toString()},
        {FMH::MODEL_KEY::TITLE, info.fileName()},
        {FMH::MODEL_KEY::SIZE, QString::number(info.size())},
        {FMH::MODEL_KEY::SOURCE,QUrl::fromLocalFile(info.absoluteDir().absolutePath()).toString ()},
        {FMH::MODEL_KEY::DATE, info.birthTime().toString(Qt::TextDate)},
        {FMH::MODEL_KEY::MODIFIED, info.lastModified().toString(Qt::TextDate)},
        {FMH::MODEL_KEY::CITY, exiv2.cityId()},
        {FMH::MODEL_KEY::FORMAT, info.completeSuffix()}};
}

Gallery::Gallery(QObject *parent)
    : MauiList(parent)
    , m_fileLoader(new FMH::FileLoader(this))
    , m_watcher(new QFileSystemWatcher(this))
    , m_scanTimer(new QTimer(this))
    , m_autoReload(true)
    , m_recursive(true)
{
    qDebug() << "CREATING GALLERY LIST";
    m_scanTimer->setSingleShot(true);
    m_scanTimer->setInterval(15000); //wait 15 secs after a new image is found and before the rescan

    m_fileLoader->setBatchCount(500);
    m_fileLoader->informer = m_activeGeolocationTags ? &picInfo2 : &picInfo;
}

Gallery::~Gallery()
{
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
    if(m_urls.isEmpty())
    {
        this->setStatus(Status::Error, i18n("No sources found to scan."));
        return;
    }

    this->setStatus(Status::Loading);
    m_fileLoader->requestPath(urls, recursive, FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::IMAGE], QDir::Files, limit);
}

void Gallery::insertFolder(const QUrl &path)
{
    if (!m_folders.contains(path)) {
        m_folders << path;

        if (m_autoReload) {
            this->m_watcher->addPath(path.toLocalFile());
        }
    }
}

void Gallery::insertCity(const QString & cityId)
{
    if (!m_cities.contains(cityId) && !cityId.isEmpty ()) {

        qDebug() << "FOUND CITY <<" << cityId;
        m_cities << cityId;
    }
}

void Gallery::setStatus(const Gallery::Status &status, const QString &error)
{
    qDebug() << "Setting up status" << status;
    this->m_status = status;
    emit this->statusChanged();


    if(error != m_error)
    {
        this->m_error = error;
        emit this->errorChanged(m_error);
    }
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

    const auto index_ = index;

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
    this->load();
}

void Gallery::load()
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
        return (std::distance(this->items().constBegin(), it));
    else
        return -1;
}

void Gallery::setActiveGeolocationTags(bool activeGeolocationTags)
{
    if (m_activeGeolocationTags == activeGeolocationTags)
        return;

    m_activeGeolocationTags = activeGeolocationTags;
    emit activeGeolocationTagsChanged(m_activeGeolocationTags);
}

void Gallery::componentComplete()
{
    connect(m_fileLoader, &FMH::FileLoader::finished, [this](FMH::MODEL_LIST items) {
        Q_UNUSED(items)

        emit this->filesChanged();
        emit this->citiesChanged();
        emit this->foldersChanged();

        this->setStatus(Status::Ready);
    });

    connect(m_fileLoader, &FMH::FileLoader::itemsReady, [this](FMH::MODEL_LIST items) {
        qDebug() << "Items ready" << items.size();

        if (items.isEmpty())
            return;

        emit preItemsAppended(items.size());
        this->list << items;
        emit postItemAppended();
        emit this->countChanged();
    });

    connect(m_fileLoader, &FMH::FileLoader::itemReady, [this](FMH::MODEL item) {
        this->insertFolder(item[FMH::MODEL_KEY::SOURCE]);
        if(m_activeGeolocationTags)
        {
            this->insertCity(item[FMH::MODEL_KEY::CITY]);
        }
    });

    connect(m_watcher, &QFileSystemWatcher::directoryChanged, [this](QString dir) {
        qDebug() << "Dir changed" << dir;
        this->m_scanTimer->start();
    });

    connect(m_scanTimer, &QTimer::timeout, [this]() {
        this->rescan();
    });

    connect(this, &Gallery::urlsChanged, this, &Gallery::rescan);
    connect(this, &Gallery::activeGeolocationTagsChanged, [this](bool state)
    {
        m_fileLoader->informer = state ? &picInfo2 : &picInfo;

        if(state)
        {
            this->rescan();
        }
    });

    this->load();
}

const QStringList &Gallery::cities() const
{
    return m_cities;
}

Gallery::Status Gallery::status() const
{
    return m_status;
}

QString Gallery::error() const
{
    return m_error;
}

bool Gallery::activeGeolocationTags() const
{
    return m_activeGeolocationTags;
}

void Gallery::scanImagesText()
{
    TextScanner scanner;
    int i = 0;

    for(auto &item : this->list)
    {
        if(!QString(item[FMH::MODEL_KEY::CONTEXT]).isEmpty())
        {
            qDebug() << "EXISTING TEXT" << item[FMH::MODEL_KEY::CONTEXT];
            continue;
        }

        QString text;
        QString url = item[FMH::MODEL_KEY::URL];

        if(TextInImages.contains(url))
        {
            text = TextInImages.value(url);
        }else
        {
            scanner.setUrl(url);
            text = scanner.getText();
            TextInImages.insert(url, text);
        }

        item[FMH::MODEL_KEY::CONTEXT] = text.isEmpty() ? "---" : text;
        qDebug() << "FOUND TEXT" << item[FMH::MODEL_KEY::CONTEXT];

        this->updateModel(i, {FMH::MODEL_KEY::CONTEXT});
        i++;
    }
}
