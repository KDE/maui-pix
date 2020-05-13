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

class QFileSystemWatcher;
class FileLoader;
class Gallery : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QList<QUrl> urls READ urls WRITE setUrls NOTIFY urlsChanged)
    Q_PROPERTY(QList<QUrl> folders READ folders NOTIFY foldersChanged)
    Q_PROPERTY(bool recursive READ recursive WRITE setRecursive NOTIFY recursiveChanged)
    Q_PROPERTY(bool autoScan READ autoScan WRITE setAutoScan NOTIFY autoScanChanged)
    Q_PROPERTY(bool autoReload READ autoReload WRITE setAutoReload NOTIFY autoReloadChanged)

public:
    explicit Gallery(QObject *parent = nullptr);
    ~Gallery();
    FMH::MODEL_LIST items() const override final;
    void setUrls(const QList<QUrl> &urls);
    QList<QUrl> urls() const;

    void setAutoScan(const bool &value);
    bool autoScan() const;

    void setAutoReload(const bool &value);
    bool autoReload() const;

    QList<QUrl> folders() const
    {
        return m_folders;
    }

    bool recursive() const
    {
        return m_recursive;
    }

private:
    FileLoader *m_fileLoader;
    QFileSystemWatcher *m_watcher;
    QList<QUrl> m_urls;
    QList<QUrl> m_folders;
    bool m_autoReload;
    bool m_autoScan;

    FMH::MODEL_LIST list = {};
    void setList();
    void scan(const QList<QUrl> &urls, const bool &recursive = true);
    void insert(const FMH::MODEL_LIST &items);

    void insertFolder(const QUrl &path);

    bool m_recursive;

signals:
    void urlsChanged();
    void foldersChanged();
    void autoReloadChanged();
    void autoScanChanged();

    void recursiveChanged(bool recursive);

public slots:
    QVariantMap get(const int &index) const;
    bool update(const int &index, const QVariant &value, const int &role); //deprecrated
    bool update(const QVariantMap &data, const int &index);
    bool update(const FMH::MODEL &pic);
    bool remove(const int &index);
    bool deleteAt(const int &index);
    void append(const QVariantMap &pic);
    void append(const QString &url);
//    void appendAt(const QString &url, const int &pos);
    void refresh();
    void clear();

    void rescan();
    void reload();
    void setRecursive(bool recursive)
    {
        if (m_recursive == recursive)
            return;

        m_recursive = recursive;
        emit recursiveChanged(m_recursive);
    }
};
Q_DECLARE_METATYPE(FMH::MODEL_LIST);

#endif // GALLERY_H
