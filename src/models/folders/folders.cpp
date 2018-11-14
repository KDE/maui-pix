#include "./src/models/folders/folders.h"
#include "./src/db/dbactions.h"

Folders::Folders(QObject *parent) : QObject(parent)
{
    qDebug()<< "CREATING GALLERY LIST";
    this->dba = DBActions::getInstance();
    this->sortList();

    connect(this, &Folders::sortByChanged, this, &Folders::sortList);
    connect(this, &Folders::orderChanged, this, &Folders::sortList);

    connect(this, &Folders::queryChanged, this, &Folders::setList);
    connect(this, &Folders::sortByChanged, this, &Folders::setList);
}

void Folders::setSortBy(const uint &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

uint Folders::getSortBy() const
{
    return this->sort;
}

FMH::MODEL_LIST Folders::items() const
{
    return this->list;
}

void Folders::setQuery(const QString &query)
{
    if(this->query == query)
        return;

    this->query = query;
    qDebug()<< "setting ALBUMS query"<< this->query;

    emit this->queryChanged();
}

QString Folders::getQuery() const
{
    return this->query;
}

void Folders::sortList()
{
    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qSort(this->list.begin(), this->list.end(), [key](const FMH::MODEL& e1, const FMH::MODEL& e2) -> bool
    {
        auto role = key;

        switch(role)
        {

        case FMH::MODEL_KEY::MODIFIED:
        case FMH::MODEL_KEY::DATE:
        {
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                return true;

            break;
        }

        case FMH::MODEL_KEY::LABEL:
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

void Folders::setList()
{
    emit this->preListChanged();

    this->list = this->dba->getFolders(this->query);
//    this->list =
//    qDebug()<< "ALBUMS LIST READY"<< list;
    this->sortList();

    emit this->postListChanged();
}

QVariantMap Folders::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    const auto folder = this->list.at(index);

    QVariantMap res;
    for(auto key : folder.keys())
        res.insert(FMH::MODEL_NAME[key], folder[key]);

    return res;
}

void Folders::refresh()
{
    this->setList();
}
