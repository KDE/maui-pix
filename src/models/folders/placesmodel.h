#pragma once
#include <QObject>
#include <QVariantList>

#include <MauiKit/Core/mauilist.h>

class PlacesModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QVariantList quickPlaces READ quickPlaces)

public:
    explicit PlacesModel(QObject *parent = nullptr);

    QVariantList quickPlaces() const;

private:
    QVariantList m_quickPlaces;
    FMH::MODEL_LIST m_list;

    void setList();
    FMH::MODEL_LIST tags();
    FMH::MODEL_LIST collectionPaths();
    FMH::MODEL_LIST locations();
    FMH::MODEL_LIST categories();
    // QQmlParserStatus interface
public:
    void classBegin() override final;
    void componentComplete() override final;

    // MauiList interface
public:
    const FMH::MODEL_LIST &items() const override final;
};

