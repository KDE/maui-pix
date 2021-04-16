#ifndef FOLDERS_H
#define FOLDERS_H

#include <QObject>

#include <MauiKit/Core/fmh.h>
#include <MauiKit/Core/mauilist.h>

class Folders : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QList<QUrl> folders READ folders WRITE setFolders NOTIFY foldersChanged)

public:
    explicit Folders(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override final;
    void setFolders(const QList<QUrl> &folders);
    QList<QUrl> folders() const;

private:
    FMH::MODEL_LIST list;
    QList<QUrl> m_folders;
    void packPreviewImages(FMH::MODEL &folder);

public slots:
    QVariantMap get(const int &index) const;
    void refresh();

signals:
    void foldersChanged();
};

#endif // ALBUMS_H
