#pragma once

#include <MauiKit4/Core/fmh.h>
#include <MauiKit4/Core/mauilist.h>

class Tagging;
class TagsModel : public MauiList
{
    Q_OBJECT

public:
    explicit TagsModel(QObject *parent = nullptr);
    ~TagsModel();
    const FMH::MODEL_LIST &items() const override;
    void componentComplete() override;

private:
    Tagging *m_tagging;
    FMH::MODEL_LIST list;
    void setList();

    FMH::MODEL_LIST tags();

    void packPreviewImages(FMH::MODEL &tag);
};
