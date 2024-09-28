#pragma once

#include <QQuickImageProvider>
#include <QCache>

class Surface : public QObject
{
    Q_OBJECT

    typedef QCache<QString, QImage> ThumbCache;

public:
    Surface(QObject *p = nullptr);
    void request(const QString &path, int width, int);

private:
    ThumbCache m_thumbCache;

Q_SIGNALS:
    void previewReady(QImage image);
    void error(QString error);
};

class AsyncImageResponse : public QQuickImageResponse
{
public:
    AsyncImageResponse(const QString &id, const QSize &requestedSize);
    QQuickTextureFactory *textureFactory() const override;
    QString errorString() const override;

private:
    QString m_id;
    QSize m_requestedSize;
    QImage m_image;
    QString m_error;
};

class Thumbnailer : public QQuickAsyncImageProvider
{
public:
    QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override;
};
