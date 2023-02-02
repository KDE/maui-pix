#include "placesmodel.h"
#include <KI18n/KLocalizedString>
#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/tagging.h>


static QUrl cameraPath()
{
    const static auto paths = QStringList{FMStatic::HomePath + "/DCIM/Camera", FMStatic::HomePath + "/Camera", FMStatic::PicturesPath+"/Camera", FMStatic::PicturesPath+"/camera"};

    for (const auto &path : paths) {
        if (FMH::fileExists(path))
            return QUrl(path);
    }

    return QUrl();
}

static QUrl screenshotsPath()
{
    const static auto paths = QStringList{FMStatic::HomePath + "/DCIM/Screenshots", FMStatic::HomePath + "/Screenshots",FMStatic::PicturesPath+"/screenshots" , FMStatic::PicturesPath+"/Screenshots"};

    for (const auto &path : paths) {
        if (FMH::fileExists(path))
            return QUrl(path);
    }

    return QUrl();
}

PlacesModel::PlacesModel(QObject *parent) : MauiList(parent)
{
    m_quickPlaces << QVariantMap{{"icon", "love"}, {"path", "tags:///fav"}, {"label", i18n("Favorites")}};
    m_quickPlaces << QVariantMap{{"icon", "folder-download"}, {"path", FMStatic::DownloadsPath}, {"label", i18n("Downloads")}};
    m_quickPlaces << QVariantMap{{"icon", "folder-pictures"}, {"path", FMStatic::PicturesPath}, {"label", i18n("Documents")}};
    m_quickPlaces << QVariantMap{{"icon", "org.gnome.Screenshot-symbolic"}, {"path", screenshotsPath().toString()}, {"label", i18n("Screenshots")}};
    m_quickPlaces << QVariantMap{{"icon", "camera-web"}, {"path",cameraPath().toString()}, {"label", i18n("Camera")}};
//    m_quickPlaces << QVariantMap{{"icon", "view-list-icons"}, {"path", "collection:///"}, {"label", i18n("Collection")}};
//    m_quickPlaces << QVariantMap{{"icon", "love"}, {"path", "tags:///wallpapers"}, {"label", i18n("Wallpapers")}};

    connect(Tagging::getInstance(), &Tagging::tagged, [this](QVariantMap item) {
           emit this->preItemAppended();
        auto tag = FMH::toModel(item);
        tag[FMH::MODEL_KEY::TYPE] = i18n("Tags");
        tag[FMH::MODEL_KEY::PATH] = QString("tags:///%1").arg(tag[FMH::MODEL_KEY::TAG]);
          m_list << tag;
           emit this->postItemAppended();
       });
}

QVariantList PlacesModel::quickPlaces() const
{
    return m_quickPlaces;
}

void PlacesModel::setList()
{
    emit this->preListChanged();
    m_list << this->tags();
    emit this->postListChanged();
    emit this->countChanged();
}

FMH::MODEL_LIST PlacesModel::tags()
{
    FMH::MODEL_LIST res;
    const auto tags = Tagging::getInstance()->getUrlsTags(true);

    return std::accumulate(tags.constBegin(), tags.constEnd(), res, [this](FMH::MODEL_LIST &list, const QVariant &item) {
        auto tag = FMH::toModel(item.toMap());
        tag[FMH::MODEL_KEY::TYPE] = i18n("Tags");
        tag[FMH::MODEL_KEY::PATH] = QString("tags:///%1").arg(tag[FMH::MODEL_KEY::TAG]);
        m_list << tag;
        return list;
    });
}


void PlacesModel::classBegin()
{
}

void PlacesModel::componentComplete()
{
   this->setList();
}

const FMH::MODEL_LIST &PlacesModel::items() const
{
    return m_list;
}
