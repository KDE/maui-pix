#ifndef PICINFOMODEL_H
#define PICINFOMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <MauiKit/mauilist.h>

class ReverseGeoCoder;
class PicInfoModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY (QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    enum ROLES
    {
        KEY,
        VALUE
    };
    explicit PicInfoModel(QObject *parent = nullptr);
    ~PicInfoModel();

    QUrl url() const
    {
        return m_url;
    }

public slots:
    void setUrl(QUrl url)
    {
        if(!FMH::fileExists(url))
        {
            return;
        }

        if (m_url == url)
            return;

        m_url = url;
        emit urlChanged(m_url);
        this->parse();
    }

private:
    QUrl m_url;
    FMH::MODEL_LIST m_data;
    ReverseGeoCoder* m_geoCoder;

    void parse();

signals:
    void urlChanged(QUrl url);

    // MauiList interface
public:
    FMH::MODEL_LIST items() const override;
};

#endif // PICINFOMODEL_H
