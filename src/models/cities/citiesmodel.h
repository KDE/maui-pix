#ifndef CITIESMODEL_H
#define CITIESMODEL_H

#include <QObject>

#include <MauiKit/Core/fmh.h>
#include <MauiKit/Core/mauilist.h>

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

signals:
  void citiesChanged();

};

#endif // CITIESMODEL_H
