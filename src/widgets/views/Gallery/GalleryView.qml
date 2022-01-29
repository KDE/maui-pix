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

    holder.emoji: "qrc:/assets/image-multiple.svg"
    holder.title : i18n("No Pics!")
    holder.body: mainGalleryList.status === GalleryList.Error ? mainGalleryList.error : i18n("Nothing here. You can add new sources or open an image.")
    holder.actions:[
    Action
        {
            text: i18n("Open")
            onTriggered: openFileDialog()
        },

        Action
        {
            text: i18n("Add sources")
            onTriggered: openSettingsDialog()
        }
    ]

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
                control.filterCity("")
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
                    cities: mainGalleryList.cities
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
                        control.filterCity(model.id)
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
