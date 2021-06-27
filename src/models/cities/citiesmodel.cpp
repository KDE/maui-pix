#include "citiesmodel.h"

#include <MauiKit/ImageTools/cities.h>
#include <MauiKit/ImageTools/city.h>

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
    emit citiesChanged();
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
    emit this->preListChanged();
    this->m_list.clear();
    Cities cities;
    for (const auto &cityId : std::as_const(m_cities)) {
        const auto city = cities.city(cityId);
        this->m_list << FMH::MODEL( {
                                        {FMH::MODEL_KEY::COUNTRY, city.country()},
                                        {FMH::MODEL_KEY::ID, city.id()},
                                        {FMH::MODEL_KEY::NAME, city.name()}
                                    });
    }
    emit this->postListChanged();
}
