#ifndef GALLERY_H
#define GALLERY_H

#include <QObject>
#include <QStringList>

#include <MauiKit/Core/mauilist.h>

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
    Q_PROPERTY(QStringList cities READ cities NOTIFY citiesChanged FINAL)
    Q_PROPERTY(QStringList files READ files NOTIFY filesChanged FINAL)

    Q_PROPERTY(bool recursive READ recursive WRITE setRecursive NOTIFY recursiveChanged)
    Q_PROPERTY(bool autoReload READ autoReload WRITE setAutoReload NOTIFY autoReloadChanged)
    Q_PROPERTY(int limit READ limit WRITE setlimit NOTIFY limitChanged)

    Q_PROPERTY(Status status READ status NOTIFY statusChanged FINAL)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged FINAL)

    Q_PROPERTY(bool activeGeolocationTags READ activeGeolocationTags WRITE setActiveGeolocationTags NOTIFY activeGeolocationTagsChanged)

public:
    enum Status
    {
        Ready,
        Loading,
        Error
    };
    Q_ENUM(Status)

    explicit Gallery(QObject * = nullptr);
    ~Gallery();

    void componentComplete() override;

    const FMH::MODEL_LIST &items() const override final;

    void setUrls(const QList<QUrl> &);
    QList<QUrl> urls() const;

    void setAutoReload(const bool &);
    bool autoReload() const;

    QList<QUrl> folders() const;

    bool recursive() const;

    int limit() const;

    QStringList files() const;

    const QStringList &cities() const;

    Status status() const;

    QString error() const;

    bool activeGeolocationTags() const;

private:
    FMH::FileLoader *m_fileLoader;
    QFileSystemWatcher *m_watcher;

    FMH::MODEL_LIST list = {};

    QList<QUrl> m_urls;
    QStringList m_cities;
    QList<QUrl> m_folders;

    bool m_autoReload;
    bool m_recursive;
    int m_limit = PIX_QUERY_MAX_LIMIT;

    Status m_status = Status::Error;
    QString m_error;

    QList<QUrl> extractTags(const QList<QUrl> &);

    void scan(const QList<QUrl> &, const bool & = true, const int & = PIX_QUERY_MAX_LIMIT);
    void scanTags(const QList<QUrl> &, const int & = PIX_QUERY_MAX_LIMIT);

    void insert(const FMH::MODEL_LIST &);

    void insertFolder(const QUrl &);
    void insertCity(const QString &);

    void setStatus(const Gallery::Status &, const QString& = QString());

    bool m_activeGeolocationTags = false;

signals:
    void urlsChanged();
    void foldersChanged();
    void autoReloadChanged();
    void recursiveChanged(bool recursive);

    void limitChanged(int limit);

    void filesChanged();

    void citiesChanged();

    void statusChanged();
    void errorChanged(QString error);

    void activeGeolocationTagsChanged(bool activeGeolocationTags);

public slots:
    bool remove(const int &);
    bool deleteAt(const int &);

    void append(const QVariantMap &);
    void append(const QString &);

    void clear();
    void rescan();
    void load();

    void setRecursive(bool);
    void setlimit(int);

    int indexOfName(const QString &);
    void setActiveGeolocationTags(bool activeGeolocationTags);
};
#endif // GALLERY_H
