#include "cloud.h"

Cloud::Cloud(QObject *parent) : BaseList (parent)
{
    this->fm = FM::getInstance();
    this->setList();

    connect(this->fm, &FM::cloudServerContentReady, [this](const FMH::MODEL_LIST &list, const QString &url)
    {
        Q_UNUSED(url);
        emit this->preListChanged();
        this->list = list;
        this->formatList();
        emit this->postListChanged();
    });
}

FMH::MODEL_LIST Cloud::items() const
{
    return this->list;
}

void Cloud::setAccount(const QString value)
{
    if(this->account == value)
        return;

    this->account = value;
    emit this->accountChanged();

    this->setList();
}

QString Cloud::getAccount() const
{
    return this->account;
}

void Cloud::setList()
{
    this->fm->getCloudServerContent(FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::CLOUD_PATH]+"/"+this->account, FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], 3);
}

void Cloud::formatList()
{
    for(auto &item : this->list)
    {
        auto url = item[FMH::MODEL_KEY::URL];
        auto thumbnail = item[FMH::MODEL_KEY::THUMBNAIL];

        item[FMH::MODEL_KEY::FAV] = QString("0");
        item[FMH::MODEL_KEY::URL] = thumbnail;
        item[FMH::MODEL_KEY::SOURCE] = url;
        item[FMH::MODEL_KEY::TITLE] = item[FMH::MODEL_KEY::LABEL];
    }
}

QVariantMap Cloud::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto pic = this->list.at(index);

    for(auto key : pic.keys())
        res.insert(FMH::MODEL_NAME[key], pic[key]);

    return res;
}
