// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.10

import QtQuick.Controls 2.10
import QtQuick.Layouts 1.12

import org.maui.pix 1.0 as Pix
import org.mauikit.controls 1.3 as Maui
import org.maui.pix 1.0

import "../../../view_models"

PixGrid
{
    id: control

    list.activeGeolocationTags: true

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

    footerColumn: [

        Control
        {
            width: parent.width
            height: _tagsRow.implicitHeight + topPadding+ bottomPadding
            padding: Maui.Style.space.medium
            contentItem: Row
            {
                id: _tagsRow
                //            height: visible ? 80 : 0
                spacing: Maui.Style.space.medium

                ToolButton
                {
                    visible: control.model.filters.length > 0
                    icon.name: "go-previous"
                    onClicked:
                    {
                        control.model.clearFilters()
                    }
                }

                Maui.Chip
                {
                    iconSource: "player_play"
                    text: i18n("Animated")
                    color: "pink"
                    //                label2.text: i18n ("GIF, AVIF")
                    onClicked:
                    {
                        //                    control.model.filterRole = "format"
                        control.model.filters = ["gif","avif"]
                    }
                }

                Maui.Chip
                {
                    iconSource: "monitor"
                    text: i18n("Screenshots")
                    color: "orange"
                    //                label2.text: i18n ("GIF, AVIF")
                    onClicked: control.model.filters = ["screenshot","screen"]
                }

                Maui.Chip
                {
                    iconSource: "animal"
                    text: i18n("Animals")
                    color: "yellow"
                    //                label2.text: i18n ("GIF, AVIF")
                }
            }
        },

        RowLayout
        {
//            visible: _geoFilterList.count > 0
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
                    control.model.clearFilters()
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

                delegate: Maui.ListBrowserDelegate
                {
                    height: 60
                    width: 200
                    isCurrentItem: ListView.isCurrentItem
                    iconSource: "mark-location"
                    label1.text: model.name
                    label2.text: model.country
                    iconVisible: true
                    onClicked:
                    {
                        onClicked: _geoFilterList.currentIndex = index
                        control.filterCity(model.id)
                        ListView.view.currentIndex = index
                    }
                }
            }
        }]



    function filterCity(cityId)
    {
        listModel.filter = cityId
    }
}
