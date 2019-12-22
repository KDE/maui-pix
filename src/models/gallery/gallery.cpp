#include "gallery.h"
#include "./src/db/dbactions.h"

Gallery::Gallery(QObject *parent) : MauiList(parent)
{
    qDebug()<< "CREATING GALLERY LIST";
    this->dba = DBActions::getInstance();
    connect(this, &Gallery::sortByChanged, this, &Gallery::sortList);
    connect(this, &Gallery::orderChanged, this, &Gallery::sortList);

    connect(this, &Gallery::queryChanged, this, &Gallery::setList);
    connect(this, &Gallery::sortByChanged, this, &Gallery::setList);
}

void Gallery::setSortBy(const SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

Gallery::SORTBY Gallery::getSortBy() const
{
    return this->sort;
}

FMH::MODEL_LIST Gallery::items() const
{
    return this->list;
}

void Gallery::setQuery(const QString &query)
{
    if(this->query == query)
        return;

    this->query = query;
    qDebug()<< "setting query"<< this->query;

    emit this->queryChanged();
}

QString Gallery::getQuery() const
{
    return this->query;
}

void Gallery::sortList()
{
    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qDebug()<< "SORTING LIST BY"<< this->sort;
    std::sort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        auto role = key;

        switch(role)
        {
            case FMH::MODEL_KEY::SIZE:
            case FMH::MODEL_KEY::FAV:
            {
                if(e1[role].toDouble() > e2[role].toDouble())
                    return true;
                break;
            }

            case FMH::MODEL_KEY::DATE:
            case FMH::MODEL_KEY::ADDDATE:
            {
                auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
                auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

                if(date1 > date2)
                    return true;

                break;

            }

            case FMH::MODEL_KEY::TITLE:
            case FMH::MODEL_KEY::PLACE:
            case FMH::MODEL_KEY::FORMAT:
            {
                const auto str1 = QString(e1[role]).toLower();
                const auto str2 = QString(e2[role]).toLower();

                if(str1 < str2)
                    return true;
                break;
            }

            default:
                if(e1[role] < e2[role])
                    return true;
        }

        return false;
    });
}

void Gallery::setList()
{
    emit this->preListChanged();

    this->list = this->dba->getDBData(this->query, [&](FMH::MODEL &item) {
            const auto url = QUrl::fromLocalFile(item[FMH::MODEL_KEY::URL]);
    if(FMH::fileExists(url))
        return true;
    else
    {
        this->dba->removePic(url.toString());
        return false;
    }
});

    qDebug()<< this->list;
    this->sortList();

    emit this->postListChanged();
}

QVariantMap Gallery::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto pic = this->list.at(index);

    for(auto key : pic.keys())
        res.insert(FMH::MODEL_NAME[key], pic[key]);

    return res;
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

    emit this->preItemRemoved(index);
    auto item = this->list.takeAt(index);
    this->dba->deletePic(item[FMH::MODEL_KEY::URL]);
    emit this->postItemRemoved();

    return true;
}

bool Gallery::fav(const int &index, const bool &value)
{
    if(index >= this->list.size() || index < 0)
        return false;

    if(this->dba->favPic(this->list[index][FMH::MODEL_KEY::URL], value))
    {
        this->list[index].insert(FMH::MODEL_KEY::FAV, value ? "1" : "0");
        return true;
    }

    return false;
}

void Gallery::append(const QVariantMap &pic)
{
    emit this->preItemAppended();

    for(auto key : pic.keys())
        this->list << FMH::MODEL {{FMH::MODEL_NAME_KEY[key], pic[key].toString()}};

    emit this->postItemAppended();
}

void Gallery::append(const QString &url)
{
    emit this->preItemAppended();

    if(this->dba->checkExistance("images", "url", url))
        this->list << this->dba->getDBData(QString("select * from images where url = '%1'").arg(url));
    else
    {
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
    }
    emit this->postItemAppended();
}

void Gallery::refresh()
{
    this->setList();
}

void Gallery::clear()
{
    emit this->preListChanged();
    this->list.clear();
    emit this->postListChanged();
}
