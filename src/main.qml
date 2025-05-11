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
import QtCore
import QtQuick.Controls
import QtQuick.Layouts

import QtQuick.Window

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.mauikit.imagetools as IT
import org.maui.pix as Pix

import "widgets"
import "widgets/views"

Maui.ApplicationWindow
{
    id: root
    title: initData

    Maui.Style.styleType: _appView.pixViewer.visible ? Maui.Style.Dark : undefined

    readonly property bool fullScreen : root.visibility === Window.FullScreen
    readonly property alias selectionBox : _selectionBar
    property bool selectionMode : false

    property alias appView: _appView
    property alias pixViewer: _appView.pixViewer

    readonly property var previewSizes: ({small: 72,
                                             medium: 90,
                                             large: 120,
                                             extralarge: 160})


    Maui.InfoDialog
    {
        id: _confirmCloseDialog
        property bool prevent : true
        template.iconSource: "dialog-warning"
        message: i18n("There are multiple windows still open. Are you sure you want to close the application?")
        standardButtons: Dialog.Yes | Dialog.Cancel
        onAccepted:
        {
            prevent = false
            root.close()
        }

        onRejected:
        {
            prevent = true
            close()
        }
    }

    onClosing: (close) =>
               {
                   console.log("Inwdows opened" , Maui.App.windowsOpened())
                   if(Maui.App.windowsOpened() > 1 && _confirmCloseDialog.prevent)
                   {
                       _confirmCloseDialog.open()
                       close.accepted = false
                       return
                   }

                   close.accepted = true
               }

    Settings
    {
        id: browserSettings
        category: "Browser"
        property bool showLabels : false
        property bool fitPreviews : false
        property bool autoReload: true
        property int previewSize : previewSizes.medium
        property string sortBy : "modified"
        property int sortOrder: Qt.DescendingOrder
        property bool gpsTags : false
        property string lastUsedTag
    }

    Settings
    {
        id: viewerSettings
        property bool tagBarVisible : true
        property bool previewBarVisible : false
        property bool enableOCR: Maui.Handy.isLinux
        property int ocrConfidenceThreshold: 40
        property int ocrBlockType : 0 // 0-word 1-line 2-paragraph
        property int ocrSelectionType: 0 //0-free 1-rectangular
        property bool ocrPreprocessing : false
        property int ocrSegMode: IT.OCR.Auto
    }

    AppView
    {
        id: _appView
        anchors.fill: parent
        stackView.initialItem: initModule === "viewer" ? pixViewer : collectionViewComponent
        anchors.bottomMargin: _selectionBar.visible && pixViewer.visible ? _selectionBar.height : 0

        pixViewer.headBar.farLeftContent: ToolButton
        {
            icon.name: "go-previous"
            text: i18n("Gallery")
            display: ToolButton.TextBesideIcon
            onClicked: _appView.toggleViewer()
        }

    }

    SelectionBar
    {
        id: _selectionBar
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)

        maxListHeight: root.height - Maui.Style.space.medium
        display: ToolButton.IconOnly
    }

    background: Rectangle
    {
        Maui.Theme.colorSet:Maui.Theme.View
        color: Maui.Theme.backgroundColor
        radius: Maui.Style.radiusV
    }

    Component
    {
        id: _windowViewerComponent

        Maui.ApplicationWindow
        {
            transientParent: null
            readonly property alias viewer: _appView.viewer
            readonly property alias appView : _appView

            onClosing: destroy()
            AppView
            {
                id: _appView
                Maui.Controls.showCSD: true
                anchors.fill: parent
            }
        }
    }

    Connections
    {
        target: Pix.Collection

        function onViewPics(pics)
        {
            _appView.openExternalPics(pics, 0)
        }
    }

    function fav(urls)
    {
        for(const i in urls)
            FB.Tagging.toggleFav(urls[i])
    }

    function openEditorWindow(url : string, windowed : bool)
    {
        if(windowed)
        {
            var win = _windowViewerComponent.createObject(root)
            var viewer = win.viewer
            var oldIndex = viewer.viewer.count
            viewer.viewer.appendPics(urls)
            viewer.view(Math.max(oldIndex, 0))
            win.requestActivate()
            openEditor(url, viewer)

        }else
        {
            openEditor(url, _stackView)
        }
    }

    function view(urls : var, windowed : bool)
    {
        if(windowed)
        {
            if(Maui.Handy.isLinux && !Maui.Handy.isMobile)
            {
                var win = _windowViewerComponent.createObject(root)
                var appView = win.appView
                appView.openExternalPics(urls)
                win.requestActivate()
            }
        }else
        {
            _appView.openExternalPics(urls)
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

    function filterSelection(url)
    {
        if(!selectionBox)
            return [url]

        if(selectionBox.contains(url))
        {
            return selectionBox.uris
        }else
        {
            return [url]
        }
    }
}
