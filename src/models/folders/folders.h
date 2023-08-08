#pragma once

#include <QObject>

#include <MauiKit3/Core/mauilist.h>

class Folders : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QList<QUrl> folders READ folders WRITE setFolders NOTIFY foldersChanged)

public:
    explicit Folders(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override final;
    void setFolders(const QList<QUrl> &folders);
    QList<QUrl> folders() const;
    void componentComplete() override final;

private:
    FMH::MODEL_LIST list;
    QList<QUrl> m_folders;
    void setList();

public Q_SLOTS:
    void refresh();
    QStringList getPreviews(const QString &path);

Q_SIGNALS:
    void foldersChanged();

};

