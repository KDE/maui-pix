#ifndef TAGSMODEL_H
#define TAGSMODEL_H

#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>

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

#endif // TAGSMODEL_H
