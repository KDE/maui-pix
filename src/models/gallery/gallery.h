#ifndef GALLERY_H
#define GALLERY_H

#include <QObject>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

#define PIX_QUERY_MAX_LIMIT 20000

namespace FMH
{
class FileLoader;
}

class QFileSystemWatcher;

class Gallery : public MauiList
{
	Q_OBJECT
	Q_PROPERTY(QList<QUrl> urls READ urls WRITE setUrls NOTIFY urlsChanged)
	Q_PROPERTY(QList<QUrl> folders READ folders NOTIFY foldersChanged FINAL)
	Q_PROPERTY(bool recursive READ recursive WRITE setRecursive NOTIFY recursiveChanged)
	Q_PROPERTY(bool autoReload READ autoReload WRITE setAutoReload NOTIFY autoReloadChanged)
	Q_PROPERTY(int limit READ limit WRITE setlimit NOTIFY limitChanged)

public:
	explicit Gallery(QObject *parent = nullptr);
	~Gallery();

	FMH::MODEL_LIST items() const override final;

	void setUrls(const QList<QUrl> &urls);
	QList<QUrl> urls() const;

	void setAutoReload(const bool &value);
	bool autoReload() const;

	QList<QUrl> folders() const;

	bool recursive() const;

	int limit() const;

private:
    FMH::FileLoader *m_fileLoader;
	QFileSystemWatcher *m_watcher;

	QList<QUrl> m_urls;
	QList<QUrl> m_folders;
	bool m_autoReload;

	FMH::MODEL_LIST list = {};

    void scan(const QList<QUrl> &urls, const bool &recursive = true, const int &limit = PIX_QUERY_MAX_LIMIT);
    void scanTags(const QList<QUrl> &urls, const int &limit = PIX_QUERY_MAX_LIMIT);

	void insert(const FMH::MODEL_LIST &items);

	void insertFolder(const QUrl &path);

	bool m_recursive;

    int m_limit = PIX_QUERY_MAX_LIMIT;
	QList<QUrl> extractTags(const QList<QUrl> &urls);

signals:
	void urlsChanged();
	void foldersChanged();
	void autoReloadChanged();
	void recursiveChanged(bool recursive);

	void limitChanged(int limit);

public slots:
	QVariantMap get(const int &index) const;

	bool remove(const int &index);
	bool deleteAt(const int &index);

	void append(const QVariantMap &pic);
	void append(const QString &url);
//    void appendAt(const QString &url, const int &pos);

	void clear();
	void rescan();
	void reload();

	void setRecursive(bool recursive);
	void setlimit(int limit);
};
#endif // GALLERY_H
