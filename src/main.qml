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

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.15

import QtQuick.Window 2.13
import Qt.labs.settings 1.0

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.imagetools 1.3 as IT
import org.maui.pix 1.0 as Pix

import "widgets"
import "widgets/views"
import "widgets/views/Viewer"

import "widgets/views/Viewer/Viewer.js" as VIEWER

Maui.ApplicationWindow
{
    id: root
    title: _pixViewer.currentPic.title || Maui.App.displayName

    Maui.Style.styleType: Maui.Handy.isAndroid ? (browserSettings.darkMode ? Maui.Style.Dark : Maui.Style.Light) : undefined
    property alias dialog : dialogLoader.item


    /*PROPS*/
    readonly property bool fullScreen : root.visibility === Window.FullScreen
    property bool selectionMode : false

    readonly property var previewSizes: ({small: 72,
                                             medium: 90,
                                             large: 120,
                                             extralarge: 160})
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
        property bool darkMode : true
        property bool gpsTags : false
    }

    Settings
    {
        id: viewerSettings
        property bool tagBarVisible : true
        property bool previewBarVisible : false
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent

Keys.enabled: true
Keys.onEscapePressed: _stackView.pop()

        initialItem: initModule === "viewer" ? _pixViewer : _collectionViewComponent

        Loader
        {
            id: _collectionViewComponent
            active:  StackView.status === StackView.Active || item
            property string pendingFolder : initModule === "folder" ? initData : ""

            sourceComponent: CollectionView {}
        }

        PixViewer
        {
            id: _pixViewer
            visible: StackView.status === StackView.Active
            showCSDControls: initModule === "viewer"
        }
    }

    Rectangle
    {
        anchors.fill: parent
        visible: _dropArea.containsDrag

        color: Qt.rgba(Maui.Theme.backgroundColor.r, Maui.Theme.backgroundColor.g, Maui.Theme.backgroundColor.b, 0.95)

        Maui.Rectangle
        {
            anchors.fill: parent
            anchors.margins: Maui.Style.space.medium
            color: "transparent"
            borderColor: Maui.Theme.textColor
            solidBorder: false

            Maui.Holder
            {
                anchors.fill: parent
                visible: true
                emoji: "qrc:/img/assets/add-image.svg"
                emojiSize: Maui.Style.iconSizes.huge
                title: i18n("Open images")
                body: i18n("Drag and drop images here.")
            }
        }
    }

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                VIEWER.openExternalPics(drop.urls, 0)
            }
        }

        onEntered:
        {
            if(drag.source)
            {
                return
            }

            _stackView.push(_pixViewer)
        }
    }

    Component
    {
        id: _infoDialogComponent
        IT.ImageInfoDialog {}
    }

    Component
    {
        id: tagsDialogComponent
        FB.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
            composerList.strict: false
        }
    }

    Component
    {
        id: fmDialogComponent
        FB.FileDialog
        {
            settings.filterType: FB.FMList.IMAGE
            settings.onlyDirs: true
            mode: modes.OPEN
        }
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog {}
    }

    Component
    {
        id: _removeDialogComponent

        Maui.FileListingDialog
        {
            id: removeDialog
            urls: selectionBox.uris
            title: i18np("Delete %1 file?", "Delete %1 files?", urls.length)
//            acceptButton.text: i18n("Cancel")
//            rejectButton.text: i18n("Accept")

            message: i18np("Are sure you want to delete this file? This action can not be undone.", "Are sure you want to delete these files? This action can not be undone.", urls.length)

            onAccepted: close()
            onRejected:
            {
                FB.FM.removeFiles(removeDialog.urls)
                selectionBox.clear()
                close()
            }
        }
    }

    Loader { id: dialogLoader }

    FB.OpenWithDialog
    {
        id: _openWithDialog
    }

    Connections
    {
        target: Pix.Collection

        function onViewPics(pics)
        {
            VIEWER.openExternalPics(pics, 0)
        }
    }

    Component.onCompleted:
    {
        if(Maui.Handy.isAndroid)
        {
            setAndroidStatusBarColor()
        }
    }

    function setAndroidStatusBarColor()
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor( Maui.Theme.backgroundColor, !browserSettings.darkMode)
            Maui.Android.navBarColor(Maui.Theme.backgroundColor, !browserSettings.darkMode)
        }
    }

    function setPreviewSize(size)
    {
        console.log(size)
        browserSettings.previewSize = size
    }

    function getFileInfo(url)
    {
        dialogLoader.sourceComponent= _infoDialogComponent
        dialog.url = url
        dialog.open()
    }

    function toogleTagbar()
    {
        viewerSettings.tagBarVisible = !viewerSettings.tagBarVisible
    }

    function tooglePreviewBar()
    {
        viewerSettings.previewBarVisible = !viewerSettings.previewBarVisible
    }

    function toogleFullscreen()
    {
        if(root.visibility === Window.FullScreen)
        {
            root.showNormal()
        }else
        {
            root.showFullScreen()
        }
    }

    function toggleViewer()
    {
        if(_pixViewer.visible)
        {
            if(_stackView.depth === 1)
            {
                _stackView.replace(_pixViewer, _collectionViewComponent)

            }else
            {
                _stackView.pop()
            }

        }else
        {
            _stackView.push(_pixViewer)
        }

        _stackView.currentItem.forceActiveFocus()
    }

    function openFileDialog()
    {
        dialogLoader.sourceComponent = fmDialogComponent
        dialog.mode = dialog.modes.OPEN
        dialog.settings.filterType = FB.FMList.IMAGE
        dialog.settings.onlyDirs= false
        dialog.callback = function(paths)
        {
            Pix.Collection.openPics(paths)
            dialogLoader.sourceComponent = null
        };
        dialog.open()
    }

    function openSettingsDialog()
    {
        dialogLoader.sourceComponent = _settingsDialogComponent
        dialog.open()
    }

    function openFolder(url, filters)
    {
        if(!_collectionViewComponent.visible)
        {
            toggleViewer()
        }

        _collectionViewComponent.item.openFolder(url, filters)
    }
}
