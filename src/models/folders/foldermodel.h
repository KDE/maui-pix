#ifndef FOLDERMODEL_H
#define FOLDERMODEL_H

#include <QList>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/mauilist.h>
#endif


class Folders;
class FolderModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(Folders *list READ getList WRITE setList)

public:
    explicit FolderModel(QObject *parent = nullptr);

    // Basic functionality:
   FMH::MODEL_LIST items() const override final;

    Folders* getList() const;
    void setList(Folders *value);

private:
    Folders *mList;
signals:
    void listChanged();
};

#endif // NOTESMODEL_H
