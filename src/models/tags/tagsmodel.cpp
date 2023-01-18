#include "tagsmodel.h"

#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/tagging.h>

TagsModel::TagsModel(QObject *parent)
    : MauiList(parent)
{
    connect(Tagging::getInstance(), &Tagging::tagged, [this](QVariantMap tag) {
        emit this->preItemAppended();
        this->list << FMH::toModel(tag);
        emit this->postItemAppended();
    });

    connect(Tagging::getInstance(), &Tagging::urlTagged, [this](QString url, QString tag) {
        const auto index = (this->indexOf(FMH::MODEL_KEY::TAG, tag));
        auto item = this->list[index];
        auto previews = item[FMH::MODEL_KEY::PREVIEW].split(",", Qt::SkipEmptyParts);

        if (previews.size() == 4) {
            previews.pop_back();
        }

        previews.insert(0, url);
        previews.removeDuplicates();

        item[FMH::MODEL_KEY::PREVIEW] = previews.join(",");
        this->list[index] = item;
        emit this->updateModel(index, {});
    });
}

void TagsModel::componentComplete()
{
    this->setList();
}

const FMH::MODEL_LIST &TagsModel::items() const
{
    return this->list;
}

void TagsModel::setList()
{
    emit this->preListChanged();
    this->list << this->tags();
    emit this->postListChanged();
    emit this->countChanged();
}

FMH::MODEL_LIST TagsModel::tags()
{
    FMH::MODEL_LIST res;
    const auto tags = Tagging::getInstance()->getUrlsTags(true);

    return std::accumulate(tags.constBegin(), tags.constEnd(), res, [this](FMH::MODEL_LIST &list, const QVariant &item) {
        auto tag = FMH::toModel(item.toMap());
//        packPreviewImages(tag);
         tag[FMH::MODEL_KEY::TYPE] = "tag";
        list << tag;
        return list;
    });
}

void TagsModel::packPreviewImages(FMH::MODEL &tag)
{
    const auto urls = Tagging::getInstance()->getTagUrls(tag[FMH::MODEL_KEY::TAG], {}, true, 4, "image");
    tag[FMH::MODEL_KEY::PREVIEW] = QUrl::toStringList(urls).join(",");
}
