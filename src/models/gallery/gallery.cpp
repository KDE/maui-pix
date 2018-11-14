#include "gallery.h"
#include "./src/db/dbactions.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

Gallery::Gallery(QObject *parent) : BaseList(parent)
{
    qDebug()<< "CREATING GALLERY LIST";
    this->dba = DBActions::getInstance();
    this->sortList();

    connect(this, &Gallery::sortByChanged, this, &Gallery::sortList);
    connect(this, &Gallery::orderChanged, this, &Gallery::sortList);

    connect(this, &Gallery::queryChanged, this, &Gallery::setList);
    connect(this, &Gallery::sortByChanged, this, &Gallery::setList);
}

void Gallery::setSortBy(const uint &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

uint Gallery::getSortBy() const
{
    return this->sort;
}

PIX::DB_LIST Gallery::items() const
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
    const auto key = static_cast<PIX::KEY>(this->sort);
    qDebug()<< "SORTING LIST BY"<< this->sort;
    qSort(this->list.begin(), this->list.end(), [key](const PIX::DB& e1, const PIX::DB& e2) -> bool
    {
        auto role = key;

        switch(role)
        {
        case PIX::KEY::SIZE:
        {
            if(e1[role].toDouble() > e2[role].toDouble())
                return true;
            break;
        }

        case PIX::KEY::ADD_DATE:
        case PIX::KEY::PIC_DATE:
        {
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                return true;

            break;
        }

        case PIX::KEY::TITLE:
        case PIX::KEY::PLACE:
        case PIX::KEY::FORMAT:
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

    this->list = this->dba->getDBData(this->query);
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
        res.insert(PIX::KEYMAP[key], pic[key]);

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

bool Gallery::update(const PIX::DB &pic)
{
    return false;
}

bool Gallery::remove(const int &index)
{
    return false;
}

void Gallery::append(const QVariantMap &pic)
{
    emit this->preItemAppended();

    for(auto key : pic.keys())
        this->list << PIX::DB {{PIX::MAPKEY[key], pic[key].toString()}};


    emit this->postItemAppended();
}

void Gallery::refresh()
{
    this->setList();
}
