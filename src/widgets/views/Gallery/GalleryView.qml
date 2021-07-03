// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.10

import QtQuick.Controls 2.10
import QtQuick.Layouts 1.12

import org.maui.pix 1.0 as Pix
import org.mauikit.controls 1.0 as Maui
import org.maui.pix 1.0

import "../../../view_models"

PixGrid
{
    id: control

    list.urls: Pix.Collection.sources
    list.recursive: true

    holder.emoji: "qrc:/assets/image-multiple.svg"
    holder.emojiSize: Maui.Style.iconSizes.huge
    holder.title : i18n("No Pics!")
    holder.body: list.status === GalleryList.Error ? list.error : i18n("Nothing here. Try something different!")

    footerColumn: RowLayout
    {
        visible: _geoFilterList.count > 0
        width: parent.width
        height: visible ? 80 : 0
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
