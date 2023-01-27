// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.14
import QtQml 2.14

import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.0 as FB


Loader
{
    id: control
    asynchronous: true
    active: (control.enabled && control.visible) || item

    property alias list : placesList

    FB.PlacesList
    {
        id: placesList
        groups: [FB.FMList.BOOKMARKS_PATH]
    }

    FB.PlacesList
    {
        id: quickPlaces
        groups: [FB.FMList.PLACES_PATH]
    }

    sourceComponent: Maui.ListBrowser
    {
        id: _listBrowser
        topPadding: 0
        bottomPadding: 0
        verticalScrollBarPolicy: ScrollBar.AlwaysOff

        signal placeClicked (string path, var mouse)

        holder.visible: count === 0
        holder.title: i18n("Bookmarks!")
        holder.body: i18n("Your bookmarks will be listed here")

        Binding on currentIndex
        {
            value: placesList.indexOfPath(currentBrowser.currentPath)
            restoreMode: Binding.RestoreBindingOrValue
        }

        onPlaceClicked:
        {
               root.openFolder(path)


            if(sideBar.collapsed)
                sideBar.close()
        }


        flickable.topMargin: Maui.Style.space.medium
        flickable.bottomMargin: Maui.Style.space.medium
        flickable.header: Loader
        {
            asynchronous: true
            width: parent.width
            //                height: item ? item.implicitHeight : 0
            active: appSettings.quickSidebarSection
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
                        model: Maui.BaseModel
                        {
                            list: quickPlaces
                        }

                        delegate: Item
                        {
                            Layout.preferredHeight: Math.min(50, width)
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.columnSpan: model.path === "overview:///" ? 2 : 1

                            Maui.GridBrowserDelegate
                            {
                                isCurrentItem: currentFolder === model.path
                                anchors.fill: parent
                                iconSource: model.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
                                iconSizeHint: Maui.Style.iconSize
                                template.isMask: true
                                label1.text: model.label
                                labelsVisible: false
                                tooltipText: model.label
                                flat: false
                                onClicked:
                                {
                                    _listBrowser.placeClicked(model.path, mouse)
                                    if(sideBar.collapsed)
                                        sideBar.close()
                                }
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
            label: model.label
            iconName: model.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
            iconVisible: true
            template.isMask: iconSize <= Maui.Style.iconSizes.medium

            onClicked:
            {
                _listBrowser.placeClicked(model.path, mouse)
                if(sideBar.collapsed)
                    sideBar.close()
            }

        }

        section.property: "type"
        section.criteria: ViewSection.FullString
        section.delegate: Maui.LabelDelegate
        {
            width: ListView.view.width
            label: section
            isSection: true
            //                height: Maui.Style.toolBarHeightAlt
        }
    }

}


