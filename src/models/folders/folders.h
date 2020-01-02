#ifndef FOLDERS_H
#define FOLDERS_H

#include <QObject>
#include "utils/pic.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class Folders : public MauiList
{
    Q_OBJECT

public:    
    explicit Folders(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const override final;

private:
    FMH::MODEL_LIST list;
    void setList();

public slots:    
    QVariantMap get(const int &index) const;
    void refresh();

};

#endif // ALBUMS_H
