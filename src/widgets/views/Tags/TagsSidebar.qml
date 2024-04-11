// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.pix 1.0 as Pix

import "../../../view_models"

StackView
{
    id: control

    readonly property Flickable flickable : currentItem.flickable

    FB.NewTagDialog
    {
        id: newTagDialog
    }

    initialItem: _frontPageComponent

    Component
    {
        id: tagsGrid

        TagsView
        {
            list.urls : ["tags:///"+currentTag]
            list.recursive: false

            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }
        }
    }

    Component
    {
        id: gpsGrid

        TagsView
        {
            id: _gpsList

            list: mainGalleryList
            listModel.filters : currentFilters
            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }

            holder.visible: count === 0
            holder.emoji: "qrc:/assets/image-multiple.svg"
            holder.title :  i18n("No Pics!")
            holder.body: mainGalleryList.status === Pix.GalleryList.Error ? mainGalleryList.error : (list.count > 0 ? i18n("No results found.") : i18n("Nothing here. You can add new sources or open an image."))
        }
    }

    Component
    {
        id: _frontPageComponent

        Maui.Page
        {
            id: _frontPage

            Maui.Theme.inherit: false
            Maui.Theme.colorGroup: Maui.Theme.View

            flickable: _gridView.flickable

            headBar.visible: true
            headBar.forceCenterMiddleContent: false
            headBar.middleContent: Maui.SearchField
            {
                enabled: _tagsList.count > 0
                Layout.fillWidth: true
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignCenter

                placeholderText: i18np("Filter %1 tag", "Filter %1 tags", _tagsList.count)
                onAccepted: _tagsModel.filter = text
                onCleared: _tagsModel.filter = ""
            }

            Action
            {
                id: _newTagAction
                icon.name : "list-add"
                text: i18n("New tag")
                onTriggered: newTagDialog.open()
            }

            headBar.rightContent: ToolButton
            {
                action: _newTagAction
                display: ToolButton.IconOnly
            }

            Maui.GridBrowser
            {
                id: _gridView
                anchors.fill: parent
                model: Maui.BaseModel
                {
                    id: _tagsModel
                    recursiveFilteringEnabled: true
                    sortCaseSensitivity: Qt.CaseInsensitive
                    filterCaseSensitivity: Qt.CaseInsensitive

                    list: Pix.TagsList
                    {
                        id: _tagsList
                    }
                }

                onKeyPress: (event) =>
                {
                    if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                    {
                        populateGrid(_gridView.currentItem.tag)
                    }
                }

                itemSize: Math.min(260, Math.max(100, Math.floor(width* 0.3)))
                itemHeight: itemSize + Maui.Style.rowHeight
                currentIndex: -1

                holder.visible: _gridView.count === 0
                holder.emoji: i18n("qrc:/assets/add-image.svg")
                holder.title :i18n("No Tags!")
                holder.body: i18n("You can create new tags to organize your gallery")
                holder.actions: _newTagAction

                flickable.header: Pane
                {
                    background: null
                    width: parent.width
                    implicitHeight: implicitContentHeight + topPadding + bottomPadding
                    padding: Maui.Style.space.big
                    height: implicitHeight

                    contentItem: Column
                    {
                        spacing: Maui.Style.space.medium

                        Maui.SectionGroup
                        {
                            visible: _geoFilterList.count > 0 && browserSettings.gpsTags

                            width: parent.width
                            title: i18n("Places")
                            description: i18n("GPS based locations")

                            Maui.ListBrowser
                            {
                                id:  _geoFilterList
                                implicitHeight: 80
                                Layout.fillWidth: true
                                orientation: Qt.Horizontal
                                currentIndex: -1
                                padding: 0

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
                                    iconSource: "mark-location"
                                    label1.text: model.name
                                    label2.text: model.country
                                    iconVisible: true
                                    template.isMask: true
                                    onClicked:
                                    {
                                        populateByFilter([model.id])
                                    }
                                }
                            }
                        }

                        Maui.SectionGroup
                        {
                            width: parent.width
                            title: i18n("Filters")
                            description: i18n("GPS based locations")

                            Flow
                            {
                                id: _tagsRow
                                Layout.fillWidth: true
                                //            height: visible ? 80 : 0
                                spacing: Maui.Style.space.medium

                                Maui.Chip
                                {
                                    iconSource: "media-playback-start"
                                    text: i18n("Animated")
                                    color: "#43a047"
                                    //                label2.text: i18n ("GIF, AVIF")
                                    onClicked:
                                    {
                                        //                    _frontPage.model.filterRole = "format"
                                        populateByFilter(["gif","avif"])
                                    }
                                }

                                Maui.Chip
                                {
                                    iconSource: "monitor"
                                    text: i18n("Screenshots")
                                    color: "#00acc1"
                                    onClicked: populateByFilter(["screenshot","screen"])
                                }

                                Maui.Chip
                                {
                                    iconSource: "view-calendar-birthday"
                                    text: i18n("Sunday")
                                    color: "#039be5"
                                    onClicked: populateByFilter(["sunday","Sunday"])
                                }

                                Maui.Chip
                                {
                                    iconSource: "monitor"
                                    text: i18n("PNGs")
                                    color: "#1e88e5"
                                    onClicked: populateByFilter([".png"])
                                }

                                Maui.Chip
                                {
                                    iconSource: "draw-calligraphic"
                                    text: i18n("PSD")
                                    color: "#8e24aa"
                                    onClicked: populateByFilter([".psd"])
                                }

                                Maui.Chip
                                {
                                    iconSource: "draw-arrow"
                                    text: i18n("Vectors")
                                    color: "#d81b60"
                                    onClicked: populateByFilter([".svg",".eps"])
                                }

                                Maui.Chip
                                {
                                    iconSource: "draw-brush"
                                    text: i18n("Paint")
                                    color: "#5e35b1"
                                    onClicked: populateByFilter([".xcf", ".kra"])
                                }

                                Maui.Chip
                                {
                                    iconSource: "animal"
                                    text: i18n("Animals")
                                    color: "#3949ab"
                                    //                label2.text: i18n ("GIF, AVIF")
                                }

                            }
                        }
                    }
                }

                delegate: Item
                {
                    height: GridView.view.cellHeight
                    width: GridView.view.cellWidth
                    readonly property string tag : model.tag

                    Maui.GalleryRollItem
                    {
                        anchors.fill: parent
                        anchors.margins: !root.isWide ? Maui.Style.space.tiny : Maui.Style.space.big

                        imageWidth: 120
                        imageHeight: 120

                        isCurrentItem: parent.GridView.isCurrentItem
                        images: model.preview.split(",")

                        label1.text: model.tag
                        label2.text: Qt.formatDateTime(new Date(model.adddate), "d MMM yyyy")

                        onClicked:
                        {
                            _gridView.currentIndex = index
                            if(Maui.Handy.singleClick)
                            {
                                populateGrid(model.tag)
                            }
                        }

                        onDoubleClicked:
                        {
                            _gridView.currentIndex = index
                            if(!Maui.Handy.singleClick)
                            {
                                populateGrid(model.tag)
                            }
                        }
                    }
                }
            }
        }
    }

    function refreshPics()
    {
        tagsGrid.list.refresh()
    }

    function populateGrid(myTag)
    {
        control.push(tagsGrid, {'currentTag': myTag})
    }

    function populateByFilter(filters)
    {
        control.push(gpsGrid, {'currentFilters': filters})
    }
}

