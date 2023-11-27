#pragma once
#include <MauiKit3/Core/fmh.h>
#include <MauiKit3/Core/mauilist.h>

class TagsModel : public MauiList
{
    Q_OBJECT

public:
    explicit TagsModel(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override;
    void componentComplete() override;

private:
    FMH::MODEL_LIST list;
    void setList();

    FMH::MODEL_LIST tags();

    void packPreviewImages(FMH::MODEL &tag);
};
