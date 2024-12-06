// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick
import QtQml

import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.pix as Pix

Loader
{
    id: control
    asynchronous: true
    active: (control.enabled && control.visible) || item

    readonly property alias list : placesList

    Pix.PlacesList
    {
        id: placesList
    }

    sourceComponent: Maui.ListBrowser
    {
        id: _listBrowser
        topPadding: 0
        bottomPadding: 0
        verticalScrollBarPolicy: ScrollBar.AlwaysOff

        signal placeClicked (string path, string filters, var mouse)

        holder.visible: count === 0
        holder.title: i18n("Bookmarks!")
        holder.body: i18n("Your bookmarks will be listed here")

        onPlaceClicked: (path, filters, mouse) =>
        {            
            root.openFolder(path, filters.split(","))

            if(sideBar.collapsed)
                sideBar.close()
        }

        flickable.topMargin: Maui.Style.contentMargins
        flickable.bottomMargin: Maui.Style.contentMargins
        flickable.header: Loader
        {
            asynchronous: true
            width: parent.width
            visible: active

            sourceComponent: Item
            {
                implicitHeight: _quickSection.implicitHeight

                GridLayout
                {
                    id: _quickSection
                    width: Math.min(parent.width, 180)
                    anchors.centerIn: parent
                    rows: 3
                    columns: 3
                    columnSpacing: Maui.Style.space.small
                    rowSpacing: Maui.Style.space.small

                    Repeater
                    {
                        model: placesList.quickPlaces

                        delegate: Maui.GridBrowserDelegate
                        {
                            Layout.preferredHeight: Math.min(50, width)
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.columnSpan: modelData.path === "tags:///fav" ? 2 : (modelData.path === "collection:///" ? 3 : 1)

                            isCurrentItem: currentFolder === modelData.path
                            iconSource: modelData.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true
                            label1.text: modelData.label
                            labelsVisible: false
                            tooltipText: modelData.label
                            flat: false

                            onClicked: (mouse) =>
                            {
                                _listBrowser.placeClicked(modelData.path, modelData.filters, mouse)
                                if(sideBar.collapsed)
                                    sideBar.close()
                            }
                        }

                    }
                }
            }
        }

        model: Maui.BaseModel
        {
            id: placesModel
            list: placesList
        }

        Component.onCompleted:
        {
            _listBrowser.flickable.positionViewAtBeginning()
        }

        delegate: Maui.ListDelegate
        {
            isCurrentItem: currentFolder === model.path
            width: ListView.view.width

            iconSize: Maui.Style.iconSize
            label: model.name
            iconName: model.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
            iconVisible: true
            template.isMask: iconSize <= Maui.Style.iconSizes.medium

            onClicked: (mouse) =>
            {
                _listBrowser.placeClicked(model.path, model.key, mouse)
                if(sideBar.collapsed)
                    sideBar.close()
            }
        }

        section.property: "type"
        section.criteria: ViewSection.FullString
        section.delegate: Maui.LabelDelegate
        {
            width: ListView.view.width
            text: section
            isSection: true
        }
    }
}


