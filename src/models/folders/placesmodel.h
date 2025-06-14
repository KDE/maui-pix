#pragma once
#include <QObject>
#include <QVariantList>

#include <MauiKit4/Core/mauilist.h>

class Tagging;
class PlacesModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QVariantList quickPlaces READ quickPlaces)

public:
    explicit PlacesModel(QObject *parent = nullptr);
    ~PlacesModel();
    QVariantList quickPlaces() const;

private:
    Tagging *m_tagging;
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
    const FMH::MODEL_LIST &items() const override final;
};

