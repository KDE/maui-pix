// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


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
    QFileInfo file(url.toLocalFile());

    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Name"},  {FMH::MODEL_KEY::VALUE, file.fileName()}, {FMH::MODEL_KEY::ICON, "edit-rename"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Path"},  {FMH::MODEL_KEY::VALUE, url.toLocalFile()}, {FMH::MODEL_KEY::ICON, "folder"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Last Modified"},  {FMH::MODEL_KEY::VALUE, file.lastModified().toString()}, {FMH::MODEL_KEY::ICON, "view-media-recent"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Date"},  {FMH::MODEL_KEY::VALUE, file.birthTime().toString()}, {FMH::MODEL_KEY::ICON, "view-calendar-birthday"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Type"},  {FMH::MODEL_KEY::VALUE, FMH::getMime(url)}, {FMH::MODEL_KEY::ICON, "documentinfo"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Location"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "gps"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Aperture"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "documentinfo"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Camera"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "camera-video"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Camera Model"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "documentinfo"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Focal Length"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "documentinfo"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "ISO"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "documentinfo"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Aperture"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "documentinfo"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Notes"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "note"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Author"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "user"}};
    res << FMH::MODEL {{FMH::MODEL_KEY::KEY, "Other"},  {FMH::MODEL_KEY::VALUE, "Blah"}, {FMH::MODEL_KEY::ICON, "documentinfo"}};

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
