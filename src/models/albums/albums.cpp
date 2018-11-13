#include "albums.h"
#include "./src/db/db.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "tagging.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/tagging.h>
#endif

Albums::Albums(QObject *parent) : BaseList(parent)
{
    qDebug()<< "CREATING GALLERY LIST";
    this->db = DB::getInstance();
    this->tag = Tagging::getInstance(PIX::App, PIX::version, "org.kde.pix", PIX::comment);

    this->tag =  Tagging::getInstance(PIX::App, PIX::version, "org.kde.pix", PIX::comment);
    this->sortList();

    connect(this, &Albums::sortByChanged, this, &Albums::sortList);
    connect(this, &Albums::orderChanged, this, &Albums::sortList);

    connect(this, &Albums::queryChanged, this, &Albums::setList);
    connect(this, &Albums::sortByChanged, this, &Albums::setList);
}

void Albums::setSortBy(const uint &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

uint Albums::getSortBy() const
{
    return this->sort;
}

PIX::DB_LIST Albums::items() const
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
    const auto key = static_cast<PIX::KEY>(this->sort);
    qSort(this->list.begin(), this->list.end(), [key](const PIX::DB& e1, const PIX::DB& e2) -> bool
    {
        auto role = key;

        switch(role)
        {

        case PIX::KEY::ADD_DATE:
        {
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                return true;

            break;
        }

        case PIX::KEY::ALBUM:
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

    this->list = this->db->getDBData(this->query);
    qDebug()<< "ALBUMS LIST READY"<< list;
    this->sortList();

    emit this->postListChanged();
}

bool Albums::addAlbum(const QString &album)
{
    QVariantMap albumMap
    {
        {PIX::KEYMAP[PIX::KEY::ALBUM], album},
        {PIX::KEYMAP[PIX::KEY::ADD_DATE], QDateTime::currentDateTime()}
    };

    return this->db->insert(PIX::TABLEMAP[PIX::TABLE::ALBUMS], albumMap);
}

QVariantMap Albums::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto pic = this->list.at(index);

    for(auto key : pic.keys())
        res.insert(PIX::KEYMAP[key], pic[key]);

    return res;
}

bool Albums::insert(const QVariantMap &pic)
{
    emit this->preItemAppended();

    if(this->addAlbum(pic[PIX::KEYMAP[PIX::KEY::ALBUM]].toString()))
    {
        emit postItemAppended();
        return true;
    }

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

bool Albums::update(const PIX::DB &pic)
{
    return false;
}

bool Albums::remove(const int &index)
{
    return false;
}
