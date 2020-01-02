#include "albums.h"
#include "db/dbactions.h"

Albums::Albums(QObject *parent) : BaseList(parent)
{
    qDebug()<< "CREATING GALLERY LIST";
    this->dba = DBActions::getInstance();
    this->sortList();

    connect(this, &Albums::sortByChanged, this, &Albums::sortList);
    connect(this, &Albums::orderChanged, this, &Albums::sortList);

    connect(this, &Albums::queryChanged, this, &Albums::setList);
    connect(this, &Albums::sortByChanged, this, &Albums::setList);
}

void Albums::setSortBy(const FMH::MODEL_KEY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

FMH::MODEL_KEY Albums::getSortBy() const
{
    return this->sort;
}

FMH::MODEL_LIST Albums::items() const
{
    return this->list;
}

void Albums::setQuery(const QString &query)
{
    if(this->query == query)
        return;

    this->query = query;
    qDebug()<< "setting ALBUMS query"<< this->query;

    emit this->queryChanged();
}

QString Albums::getQuery() const
{
    return this->query;
}

void Albums::sortList()
{
    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qSort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        auto role = key;

        switch(role)
        {

        case FMH::MODEL_KEY::ADDDATE:
        {
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                return true;

            break;
        }

        case FMH::MODEL_KEY::ALBUM:
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

void Albums::setList()
{
    emit this->preListChanged();

    this->list = this->dba->getDBData(this->query);
//    qDebug()<< "ALBUMS LIST READY"<< list;
    this->sortList();

    emit this->postListChanged();
}

QVariantMap Albums::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto pic = this->list.at(index);

    for(auto key : pic.keys())
        res.insert(FMH::MODEL_NAME[key], pic[key]);

    return res;
}

bool Albums::insert(const QVariantMap &pic)
{
    const auto album = pic[FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM]].toString();
    if(this->dba->addAlbum(album))
    {
        emit this->preItemAppended();
        this->list << FMH::MODEL {{FMH::MODEL_KEY::ALBUM, album}};
        emit postItemAppended();
        return true;
    }

    qDebug()<< "COUDLDNT ADD ALBUM" << album;
    return false;
}

bool Albums::update(const int &index, const QVariant &value, const int &role)
{
    return false;
}

bool Albums::update(const QVariantMap &data, const int &index)
{
    return false;
}

bool Albums::update(const FMH::MODEL &pic)
{
    return false;
}

bool Albums::remove(const int &index)
{
    return false;
}

void Albums::insertPic(const QString &album, const QString &url)
{
    //this->insert({{FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album}});

    this->dba->picAlbum(album, url);
}
