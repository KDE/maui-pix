#include "placesmodel.h"

#include <KI18n/KLocalizedString>
#include <MauiKit3/FileBrowsing/fmstatic.h>
#include <MauiKit3/FileBrowsing/tagging.h>

#include "pix.h"
#include "models/gallery/gallery.h"

#include <MauiKit3/ImageTools/cities.h>
#include <MauiKit3/ImageTools/city.h>

PlacesModel::PlacesModel(QObject *parent) : MauiList(parent)
{
    m_quickPlaces << QVariantMap{{"icon", "love"}, {"path", "tags:///fav"}, {"label", i18n("Favorites")}};
    m_quickPlaces << QVariantMap{{"icon", "folder-download"}, {"path", FMStatic::DownloadsPath}, {"label", i18n("Downloads")}};
    m_quickPlaces << QVariantMap{{"icon", "folder-pictures"}, {"path", FMStatic::PicturesPath}, {"label", i18n("Pictures")}};
    m_quickPlaces << QVariantMap{{"icon", "org.gnome.Screenshot-symbolic"}, {"path", Pix::screenshotsPath().toString()}, {"label", i18n("Screenshots")}};
    m_quickPlaces << QVariantMap{{"icon", "camera-web"}, {"path", Pix::cameraPath().toString()}, {"label", i18n("Camera")}};
    m_quickPlaces << QVariantMap{{"icon", "view-list-icons"}, {"path", "collection:///"}, {"label", i18n("Collection")}};
}

QVariantList PlacesModel::quickPlaces() const
{
    return m_quickPlaces;
}

void PlacesModel::setList()
{
    emit this->preListChanged();
    m_list.clear();
    m_list << this->tags();
    m_list << this->collectionPaths();
    m_list << this->locations();
    m_list << this->categories();
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
        tag[FMH::MODEL_KEY::NAME] = tag[FMH::MODEL_KEY::TAG];
        tag[FMH::MODEL_KEY::PATH] = QString("tags:///%1").arg(tag[FMH::MODEL_KEY::TAG]);
        list << tag;
        return list;
    });
}

FMH::MODEL_LIST PlacesModel::collectionPaths()
{
    FMH::MODEL_LIST res;
    const auto paths = Pix::getSourcePaths();

    return std::accumulate(paths.constBegin(), paths.constEnd(), res, [this](FMH::MODEL_LIST &list, const QString &path) {
        auto item = FMStatic::getFileInfoModel(path);
        item[FMH::MODEL_KEY::TYPE] = i18n("Places");
        list << item;
        return list;
    });
}

FMH::MODEL_LIST PlacesModel::locations()
{
    FMH::MODEL_LIST res;

    if(!Pix::instance()->allImagesModel()->activeGeolocationTags())
        return res;

    auto cities = Pix::instance()->allImagesModel()->cities();
    auto db = Cities::getInstance();


    return std::accumulate(cities.constBegin(), cities.constEnd(), res, [this, &db](FMH::MODEL_LIST &list, const QString &id) {
        FMH::MODEL item;

       City city = db->city(id);

        item[FMH::MODEL_KEY::ICON] = "gps";
        item[FMH::MODEL_KEY::TYPE] = i18n("Locations");
        item[FMH::MODEL_KEY::PATH] = "collection:///"+id;
        item[FMH::MODEL_KEY::KEY] = id;

        item[FMH::MODEL_KEY::COUNTRY] = city.country();
        item[FMH::MODEL_KEY::ID] = city.id();
        item[FMH::MODEL_KEY::NAME] = city.name();

        list << item;
        return list;
    });

}

FMH::MODEL_LIST PlacesModel::categories()
{
    FMH::MODEL_LIST res;

    res << FMH::MODEL {{FMH::MODEL_KEY::ICON, "media-playback-start"}, {FMH::MODEL_KEY::PATH, "collection:///animated"}, {FMH::MODEL_KEY::NAME, i18n("Animated")}, {FMH::MODEL_KEY::KEY, QStringLiteral("gif,avif")}, {FMH::MODEL_KEY::TYPE, i18n("Categories")}};

    res << FMH::MODEL {{FMH::MODEL_KEY::ICON, "monitor"}, {FMH::MODEL_KEY::PATH, "collection:///screenshots"}, {FMH::MODEL_KEY::NAME, i18n("Screenshots")}, {FMH::MODEL_KEY::KEY, QStringLiteral("screenshot,screen")}, {FMH::MODEL_KEY::TYPE, i18n("Categories")}};

    res << FMH::MODEL {{FMH::MODEL_KEY::ICON, "image"}, {FMH::MODEL_KEY::PATH, "collection:///png"}, {FMH::MODEL_KEY::NAME, i18n("PNG")}, {FMH::MODEL_KEY::KEY, QStringLiteral(".png")}, {FMH::MODEL_KEY::TYPE, i18n("Categories")}};

    res << FMH::MODEL {{FMH::MODEL_KEY::ICON, "image"}, {FMH::MODEL_KEY::PATH, "collection:///psd"}, {FMH::MODEL_KEY::NAME, i18n("PSD")}, {FMH::MODEL_KEY::KEY, QStringLiteral(".psd")}, {FMH::MODEL_KEY::TYPE, i18n("Categories")}};

    res << FMH::MODEL {{FMH::MODEL_KEY::ICON, "draw-arrow"}, {FMH::MODEL_KEY::PATH, "collection:///vectors"}, {FMH::MODEL_KEY::NAME, i18n("Vectors")}, {FMH::MODEL_KEY::KEY, QStringLiteral(".svg,.eps")}, {FMH::MODEL_KEY::TYPE, i18n("Categories")}};

    res << FMH::MODEL {{FMH::MODEL_KEY::ICON, "draw-brush"}, {FMH::MODEL_KEY::PATH, "collection:///paintings"}, {FMH::MODEL_KEY::NAME, i18n("Paintings")}, {FMH::MODEL_KEY::KEY, QStringLiteral(".xcf,.kra")}, {FMH::MODEL_KEY::TYPE, i18n("Categories")}};

    return res;
}

void PlacesModel::classBegin()
{
}

void PlacesModel::componentComplete()
{
    connect(Tagging::getInstance(), &Tagging::tagged, [this](QVariantMap item) {
        emit this->preItemAppended();
        auto tag = FMH::toModel(item);
        tag[FMH::MODEL_KEY::TYPE] = i18n("Tags");
        tag[FMH::MODEL_KEY::PATH] = QString("tags:///%1").arg(tag[FMH::MODEL_KEY::TAG]);
        m_list << tag;
        emit this->postItemAppended();
    });

    connect(Pix::instance(), &Pix::sourcesChanged, this, &PlacesModel::setList);
    connect(Pix::instance()->allImagesModel(), &Gallery::citiesChanged, this, &PlacesModel::setList);

    this->setList();

}

const FMH::MODEL_LIST &PlacesModel::items() const
{
    return m_list;
}
