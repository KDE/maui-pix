// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


/***
Pix  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Window

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.mauikit.imagetools as IT
import org.maui.pix as Pix

import "Folders"
import "Gallery"
import "Tags"
import ".."

Maui.SideBarView
{
    id: control

    readonly property var mainGalleryList : Pix.Collection.allImagesModel
    property alias selectionBox : _selectionBar
    property alias currentFolder :_foldersView.currentFolder

    Binding
    {
        target: Pix.Collection.allImagesModel
        property: "autoReload"
        value: browserSettings.autoReload
        delayed: true
    }

    Binding
    {
        target: Pix.Collection.allImagesModel
        property: "activeGeolocationTags"
        value: browserSettings.gpsTags
        delayed: true
    }

    sideBar.resizeable: false
    sideBar.preferredWidth: 200
    sideBar.autoHide: true
    sideBar.autoShow: true
    sideBar.content: Sidebar
    {
        anchors.fill: parent
    }

    Maui.PageLayout
    {
        id: swipeView
        anchors.fill: parent

        altHeader: Maui.Handy.isMobile
        floatingFooter: true
        flickable: _foldersView.currentItem.flickable
        Maui.Controls.showCSD: true

        split: width < 600 && (_goBackButton.visible)
        // splitIn: ToolBar.Footer
        headerMargins: Maui.Style.defaultPadding
        middleContent: Loader
        {
            Layout.fillWidth: true
            Layout.maximumWidth: 500
            Layout.alignment: Qt.AlignCenter
            sourceComponent: _foldersView.currentItem && _foldersView.currentItem.hasOwnProperty("searchFieldComponent") ? _foldersView.currentItem.searchFieldComponent : null
        }

        leftContent: [
            ToolButton
            {
                id: _sideBarButton
                visible: control.sideBar.collapsed

                icon.name: sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
                onClicked: sideBar.toggle()
                checked: sideBar.visible
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Toggle sidebar")
            },

            ToolButton
            {
                id: _goBackButton
                icon.name: "go-previous"
                visible: _foldersView.depth > 1
                onClicked:
                {
                    if(_foldersView.depth > 1)
                    {
                        _foldersView.pop()
                        return;
                    }
                }
            }
        ]

        rightContent: [
            Loader
            {
                asynchronous: true
                sourceComponent: _mainMenuComponent
            }]

        FoldersView
        {
            id: _foldersView
            anchors.fill: parent
        }

        property string pendingFolder : initModule === "folder" ? initData[0] : ""

        footer: SelectionBar
        {
            id: _selectionBar
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)

            maxListHeight: swipeView.height - Maui.Style.space.medium
            display: ToolButton.IconOnly
        }

        FloatingViewer
        {
            id: _floatingViewer

            DragHandler
            {
                target: _floatingViewer
                xAxis.maximum: swipeView.width - _floatingViewer.width
                xAxis.minimum: 0

                yAxis.maximum : swipeView.height - _floatingViewer.height
                yAxis.minimum: 0

                onActiveChanged:
                {
                    if(!active)
                    {
                        let newX = Math.abs(_floatingViewer.x - (swipeView.width - _floatingViewer.implicitWidth - 20))
                        _floatingViewer.y = Qt.binding(()=> { return _floatingViewer.parent.height - _floatingViewer.implicitHeight - 20})
                        _floatingViewer.x = Qt.binding(()=> { return (_floatingViewer.parent.width - _floatingViewer.implicitWidth - 20 - newX) < 0 ? 20 : swipeView.width - _floatingViewer.implicitWidth - 20 - newX})
                    }
                }
            }
        }
    }

    function openFolder(url, filters)
    {
        _foldersView.openFolder(url, filters)
    }

    function filterSelection(url)
    {
        if(selectionBox.contains(url))
        {
            return selectionBox.uris
        }else
        {
            return [url]
        }
    }

    function selectItem(item)
    {
        if(selectionBox.contains(item.url))
        {
            selectionBox.removeAtUri(item.url)
            return
        }

        selectionBox.append(item.url, item)
    }
}
