#include "thumbnailer.h"

#include <QImage>
#include <QUrl>
#include <QObject>

#include <KIO/ThumbnailRequest>

QQuickImageResponse *Thumbnailer::requestImageResponse(const QString &id, const QSize &requestedSize)
{
    AsyncImageResponse *response = new AsyncImageResponse(id, requestedSize);
    return response;
}

AsyncImageResponse::AsyncImageResponse(const QString &id, const QSize &requestedSize)
    : m_id(id)
    , m_requestedSize(requestedSize)
{
    auto surface = new Surface();

    connect(surface, &Surface::previewReady, [this](QImage img)
    {
       qDebug() << "image Ready" << img.height();
       m_image = img;
       Q_EMIT this->finished();
    });

    surface->request(QUrl::fromUserInput(id).toLocalFile(), requestedSize.width(), requestedSize.height());

    connect(surface, &Surface::error, [this](QString error)
    {
        m_error = error;
        this->cancel();
        Q_EMIT this->finished();
    });
}

QQuickTextureFactory *AsyncImageResponse::textureFactory() const
{
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

QString AsyncImageResponse::errorString() const
{
    return m_error;
}


Surface::Surface(QObject *p) : QObject(p)
{

}

void Surface::request(const QString& path, int width, int /*height*/)
{
    QImage img;

    int seqIdx = 0;

    QList<int> seekPercentages = {20,35,50,65,80};

    // We might have an embedded thumb in the video file, so we have to add 1. This gets corrected
    // later if we don't have one.
    seqIdx %= static_cast<int>(seekPercentages.size()) + 1;

    const QString cacheKey = QString("%1$%2@%3").arg(path).arg(seqIdx).arg(width);

    QImage* cachedImg = m_thumbCache[cacheKey];
    if (cachedImg) {
        img = *cachedImg;

        Q_EMIT this->previewReady(img);
        return;
    }

    // Try reading thumbnail embedded into video file
    QByteArray ba = path.toLocal8Bit();
    TagLib::MP4::File f(ba.data(), false);

    // No matter the seqIdx, we have to know if the video has an embedded cover, even if we then don't return
    // it. We could cache it to avoid repeating this for higher seqIdx values, but this should be fast enough
    // to not be noticeable and caching adds unnecessary complexity.
    if (f.isValid()) {
        TagLib::MP4::Tag* tag = f.tag();
        TagLib::MP4::ItemMap itemsListMap = tag->itemMap();
        TagLib::MP4::Item coverItem = itemsListMap["covr"];
        TagLib::MP4::CoverArtList coverArtList = coverItem.toCoverArtList();

        if (!coverArtList.isEmpty()) {
            TagLib::MP4::CoverArt coverArt = coverArtList.front();
            img.loadFromData((const uchar *)coverArt.data().data(),
                         coverArt.data().size());
        }
    }

    if (!img.isNull()) {
        // Video file has an embedded thumbnail -> return it for seqIdx=0 and shift the regular
        // seek percentages one to the right

        if (seqIdx == 0) {

            Q_EMIT this->previewReady(img);
            return;
        }

        seqIdx--;
    }

    // The previous modulo could be wrong now if the video had an embedded thumbnail.
    seqIdx %= seekPercentages.size();

    m_Thumbnailer.setThumbnailSize(width);
    m_Thumbnailer.setSeekPercentage(seekPercentages[seqIdx]);
    //Smart frame selection is very slow compared to the fixed detection
    //TODO: Use smart detection if the image is single colored.
    //m_Thumbnailer.setSmartFrameSelection(true);
    m_Thumbnailer.generateThumbnail(path, img);

    if (!img.isNull()) {
        // seqIdx 0 will be served from KIO's regular thumbnail cache.
        Q_EMIT this->previewReady(img);
        return;
    }

   Q_EMIT this->error("Image preview could not be generated");
}


