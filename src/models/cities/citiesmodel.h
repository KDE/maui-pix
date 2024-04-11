#pragma once
#include <QObject>

#include <MauiKit3/Core/fmh.h>
#include <MauiKit3/Core/mauilist.h>

class CitiesModel : public MauiList
{
  Q_OBJECT

  Q_PROPERTY(QStringList cities READ cities WRITE setCities NOTIFY citiesChanged)

  QStringList m_cities;

public:
  explicit CitiesModel(QObject *parent = nullptr);
  const QStringList &cities() const;
  void setCities(const QStringList &newCities);

  void componentComplete() override final;

  const FMH::MODEL_LIST &items() const override final;

private:
  FMH::MODEL_LIST m_list;

  void setList();

Q_SIGNALS:
  void citiesChanged();

};
