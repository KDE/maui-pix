// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick.Controls 2.10
import QtQuick 2.10

import org.maui.pix 1.0 as Pix
import org.mauikit.controls 1.0 as Maui

import "../../../view_models"


PixGrid
{
    id: galleryViewRoot
    clip: true

    list.urls: Pix.Collection.sources
    list.recursive: true
    holder.emoji: "qrc:/assets/image-multiple.svg"
    holder.title : i18n("No Pics!")
    holder.body: i18n("Add new sources to browse your image collection ")
    holder.emojiSize: Maui.Style.iconSizes.huge


    footerColumn: Maui.ListBrowser
    {
       width: parent.width
        orientation: Qt.Horizontal
        implicitHeight: 100

        model: Maui.BaseModel
        {
            list: Pix.CitiesList
            {
                cities: _galleryView.list.cities
            }
        }

        delegate: Item
        {
            height: 64
            width: 140

            Maui.ListBrowserDelegate
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                iconSource: "mark-location"
                label1.text: model.name
                label2.text: model.country

                onClicked:
                {
                    _galleryView.filterCity(model.id)
                }
            }
        }
    }

    function filterCity(cityId)
    {
        listModel.filter = cityId
    }
}
