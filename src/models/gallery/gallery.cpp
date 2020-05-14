#include "gallery.h"
#include <QFileSystemWatcher>
#include "db/fileloader.h"

Gallery::Gallery(QObject *parent) : MauiList(parent)
  , m_fileLoader(new FileLoader())
  , m_watcher (new QFileSystemWatcher(this))
  , m_autoReload(true)
  , m_autoScan(true)
  , m_recursive (true)
{
    qDebug()<< "CREATING GALLERY LIST";

    connect(m_fileLoader, &FileLoader::finished,[this](FMH::MODEL_LIST items)
    {
        qDebug() << "Items finished" << items.size();



    });

    connect(m_fileLoader, &FileLoader::itemsReady,[this](FMH::MODEL_LIST items)
    {
        qDebug() << "Items ready" << items.size() << m_urls;

        emit this->preListChanged();
        for(const auto &item : items)
        {
            this->insertFolder(item[FMH::MODEL_KEY::SOURCE]);
        }
        this-> list << items;
        emit this->postListChanged();
    });

    connect(m_fileLoader, &FileLoader::itemReady,[this](FMH::MODEL item)
    {
//        emit this->preItemAppended();
//        this->list.append(item);
//        emit this->postItemAppended();
    });

    connect(m_watcher, &QFileSystemWatcher::directoryChanged, [this](QString dir)
    {
        qDebug()<< "Dir changed" << dir;
        this->rescan();
//        this->scan({QUrl::fromLocalFile(dir)}, m_recursive);
    });

    connect(m_watcher, &QFileSystemWatcher::fileChanged, [this](QString file)
    {
        qDebug()<< "File changed" << file;

    });
}

Gallery::~Gallery()
{
    delete m_fileLoader;
}

FMH::MODEL_LIST Gallery::items() const
{
	return this->list;
}

void Gallery::setUrls(const QList<QUrl> &urls)
{
    qDebug()<< "setting urls"<< this->m_urls << urls;

    if(this->m_urls == urls)
		return;

    this->m_urls = urls;
    this->clear();
    emit this->urlsChanged();

    if(m_autoScan)
    {
        this->scan(m_urls, m_recursive);
    }
}

QList<QUrl> Gallery::urls() const
{
    return m_urls;
}

void Gallery::setAutoScan(const bool &value)
{
    if(m_autoScan == value)
        return;

    m_autoScan = value;
    emit autoScanChanged();
}

bool Gallery::autoScan() const
{
    return m_autoScan;
}

void Gallery::setAutoReload(const bool &value)
{
    if(m_autoReload == value)
        return;

    m_autoReload = value;
    emit autoReloadChanged();
}

bool Gallery::autoReload() const
{
    return m_autoReload;
}

void Gallery::scan(const QList<QUrl> &urls, const bool &recursive)
{
    m_fileLoader->requestPath(urls, recursive);
}

void Gallery::insertFolder(const QUrl &path)
{
    if(!m_folders.contains(path))
    {
        m_folders << path;

        if(m_autoReload)
        {
            this->m_watcher->addPath(path.toLocalFile());
        }

        emit foldersChanged();
    }
}

void Gallery::setList()
{
	emit this->preListChanged();


	emit this->postListChanged();
}

QVariantMap Gallery::get(const int &index) const
{
	if(index >= this->list.size() || index < 0)
		return QVariantMap();
	return FMH::toMap(this->list.at( this->mappedIndex(index)));
}

bool Gallery::update(const int &index, const QVariant &value, const int &role)
{
	return false;
}

bool Gallery::update(const QVariantMap &data, const int &index)
{
	return false;
}

bool Gallery::update(const FMH::MODEL &pic)
{
	return false;
}

bool Gallery::remove(const int &index)
{
	return false;
}

bool Gallery::deleteAt(const int &index)
{
	if(index >= this->list.size() || index < 0)
		return false;

	const auto index_ = this->mappedIndex(index);

	emit this->preItemRemoved(index_);
	auto item = this->list.takeAt(index_);
//	this->dba->deletePic(item[FMH::MODEL_KEY::URL]);
	emit this->postItemRemoved();

	return true;
}

void Gallery::append(const QVariantMap &pic)
{
	emit this->preItemAppended();

	for(const auto &key : pic.keys())
		this->list << FMH::MODEL {{FMH::MODEL_NAME_KEY[key], pic[key].toString()}};

	emit this->postItemAppended();
}

void Gallery::append(const QString &url)
{
	emit this->preItemAppended();


		QFileInfo info(url);
		auto title = info.baseName();
		auto format = info.suffix();
		auto sourceUrl = info.dir().path();

		auto picMap = FMH::getFileInfoModel(url);
		picMap[FMH::MODEL_KEY::URL] = url;
		picMap[FMH::MODEL_KEY::TITLE] = title;
		picMap[FMH::MODEL_KEY::LABEL] = title;
		picMap[FMH::MODEL_KEY::FAV] = "0";
		picMap[FMH::MODEL_KEY::RATE] = "0";
		picMap[FMH::MODEL_KEY::COLOR] = QString();
		picMap[FMH::MODEL_KEY::FORMAT] = format;
		picMap[FMH::MODEL_KEY::DATE] =  info.birthTime().toString();
		picMap[FMH::MODEL_KEY::SOURCE] = sourceUrl;

		this->list << picMap;

	emit this->postItemAppended();
}

void Gallery::refresh()
{
    this->setList();
}

void Gallery::clear()
{
	emit this->preListChanged();
    this->list = {};
    emit this->postListChanged();

    this->m_folders = {};
    emit foldersChanged();
}

void Gallery::rescan()
{
    this->clear();
    this->scan(m_urls, m_recursive);
}

void Gallery::reload()
{
    this->scan(m_urls, m_recursive);
}
