// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick.Controls 2.10
import QtQuick.Layouts 1.12
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


    footerColumn: RowLayout
    {
        width: parent.width
        height: 80
        spacing: Maui.Style.space.medium

        ToolButton
        {
            Layout.margins: Maui.Style.space.medium
            visible: _geoFilterList.currentIndex >= 0
            icon.name: "go-previous"
            onClicked:
            {
                _geoFilterList.currentIndex = -1
                _galleryView.filterCity("")
            }
        }

        Maui.ListBrowser
        {
            id:  _geoFilterList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            model: Maui.BaseModel
            {
                list: Pix.CitiesList
                {
                    cities: _galleryView.list.cities
                }
            }

            delegate: Item
            {
                height: 60
                width: 160

                Maui.ListBrowserDelegate
                {
                    isCurrentItem: parent.ListView.isCurrentItem
                    anchors.fill: parent
                    anchors.margins: Maui.Style.space.medium
                    iconSource: "mark-location"
                    label1.text: model.name
                    label2.text: model.country
                    iconVisible: true
                    onClicked:
                    {
                        onClicked: _geoFilterList.currentIndex = index
                        _galleryView.filterCity(model.id)
                    }
                }
            }
        }
    }

    function filterCity(cityId)
    {
        listModel.filter = cityId
    }
}
