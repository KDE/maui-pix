#include "picinfomodel.h"
#include "utils/picinfo/exiv2extractor.h"
#include "utils/picinfo/reversegeocoder.h"
#include <QGeoAddress>

PicInfoModel::PicInfoModel(QObject *parent) : MauiList(parent)
  , m_geoCoder( new ReverseGeoCoder)
{

}

PicInfoModel::~PicInfoModel()
{
    delete m_geoCoder;
}

static FMH::MODEL_LIST basicInfo(const QUrl &url)
{
    FMH::MODEL_LIST res;
    const FMH::MODEL model = FMH::getFileInfoModel(url);

    for(const auto key : model.keys())
    {
        FMH::MODEL m_model;
        auto value = FMH::MODEL_NAME[key];
        m_model.insert(FMH::MODEL_KEY::KEY, value.replace(0, 1, value[0].toUpper()));
        m_model.insert(FMH::MODEL_KEY::VALUE, model[key]);
        res << m_model;
    }


    return res;
}

void PicInfoModel::parse()
{
    emit preListChanged();
    m_data.clear();
    m_data << basicInfo(m_url);
    FMH::MODEL model;
    Exiv2Extractor extractor;
    extractor.extract(m_url.toLocalFile());
    if (extractor.error())
    {
        return;
    }

    double latitude = extractor.gpsLatitude();
    double longitude = extractor.gpsLongitude();

    if (latitude != 0.0 && longitude != 0.0)
    {
        if (!m_geoCoder->initialized())
        {
            m_geoCoder->init();
        }
        QVariantMap map = m_geoCoder->lookup(latitude, longitude);

        QGeoAddress addr;
        addr.setCountry(map.value("country").toString());
        addr.setState(map.value("admin1").toString());
        addr.setCity(map.value("admin2").toString());
        m_data << FMH::MODEL{{FMH::MODEL_KEY::KEY, "Location"}, {FMH::MODEL_KEY::VALUE, addr.text()}};
    }
    m_data << FMH::MODEL{{FMH::MODEL_KEY::KEY, "Origin"}, {FMH::MODEL_KEY::VALUE, extractor.dateTime().toString()}};

    qDebug()<< "File info ready" << m_data;
    emit postListChanged();
}

FMH::MODEL_LIST PicInfoModel::items() const
{
    return m_data;
}
