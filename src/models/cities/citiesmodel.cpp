#include "citiesmodel.h"

#include <MauiKit4/ImageTools/cities.h>
#include <MauiKit4/ImageTools/city.h>

CitiesModel::CitiesModel(QObject *parent) : MauiList(parent)
{

}

const QStringList &CitiesModel::cities() const
{
    return m_cities;
}

void CitiesModel::setCities(const QStringList &newCities)
{
    if (m_cities == newCities)
        return;
    m_cities = newCities;
    Q_EMIT citiesChanged();
}


void CitiesModel::componentComplete()
{
    connect(this, &CitiesModel::citiesChanged, this, &CitiesModel::setList);
    setList ();
}

const FMH::MODEL_LIST &CitiesModel::items() const
{
    return m_list;
}

void CitiesModel::setList()
{
    Q_EMIT this->preListChanged();
    this->m_list.clear();
    auto cities = Cities::getInstance();
    for (const auto &cityId : (m_cities)) {
        City city = cities->city(cityId);

        if(!city.isValid())
            continue;

        this->m_list << FMH::MODEL( {
                                        {FMH::MODEL_KEY::COUNTRY, city.country()},
                                        {FMH::MODEL_KEY::ID, city.id()},
                                        {FMH::MODEL_KEY::NAME, city.name()}
                                    });
    }
    Q_EMIT this->postListChanged();
}
