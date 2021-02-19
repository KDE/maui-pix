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
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13
import Qt.labs.settings 1.0

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.3 as Maui
import org.maui.pix 1.0 as Pix

import "widgets"
import "widgets/views/Folders"
import "widgets/views/Gallery"
import "widgets/views/Tags"
import "widgets/views/Viewer"
import "view_models"

import "widgets/views/Pix.js" as PIX
import "widgets/views/Viewer/Viewer.js" as VIEWER

import TagsList 1.0

Maui.ApplicationWindow
{
    id: root
    title: pixViewer.currentPic.title || Maui.App.displayName
    altHeader: Kirigami.Settings.isMobile

    property alias dialog : dialogLoader.item

    /*READONLY PROPS*/
    readonly property var views : ({ gallery: 0,
                                       tags: 1,
                                       folders: 2 })
    /*PROPS*/
    readonly property bool fullScreen : root.visibility === Window.FullScreen
    property bool selectionMode : false

    readonly property var previewSizes: ({small: 100,
                                             medium: 120,
                                             large: 160,
                                             extralarge: 220})
    Settings
    {
        id: browserSettings
        category: "Browser"
        property bool showLabels : !Kirigami.Settings.isMobile
        property bool fitPreviews : false
        property bool autoReload: true
        property int previewSize : previewSizes.medium
        property string sortBy : "modified"
        property int sortOrder: Qt.DescendingOrder
    }

    Settings
    {
        id: viewerSettings
        property bool tagBarVisible : true
        property bool previewBarVisible : false
    }

    floatingFooter: true
    flickable: swipeView.currentItem.item ? swipeView.currentItem.item.flickable || null : swipeView.currentItem.flickable || null

    mainMenu: [

        Action
        {
            text: i18n("Open")
            icon.name: "folder-open"
            onTriggered:
            {
                dialogLoader.sourceComponent= fmDialogComponent
                dialog.mode = dialog.modes.OPEN
                dialog.settings.filterType= Maui.FMList.IMAGE
                dialog.settings.onlyDirs= false
                dialog.callback = function(paths)
                {
                    console.log("OPEN THIS PATHS", paths)
                    Pix.Collection.openPics(paths)
                };
                dialog.open()
            }
        },

        Action
        {
            text: i18n("Settings")
            icon.name: "settings-configure"
            onTriggered:
            {
                dialogLoader.sourceComponent = _settingsDialogComponent
                dialog.open()
            }
        }
    ]

    headBar.visible: !fullScreen && swipeView.visible
    headerPositioning: ListView.InlineHeader

    StackView
    {
        id: _stackView
        anchors.fill: parent

        initialItem: Maui.AppViews
        {
            id: swipeView

            GalleryView
            {
                id: _galleryView
                Maui.AppView.title: i18n("Gallery")
                Maui.AppView.iconName: "image-multiple"
            }


            Maui.AppViewLoader
            {
                Maui.AppView.title: i18n("Tags")
                Maui.AppView.iconName: "tag"
                TagsView {}
            }

            Maui.AppViewLoader
            {
                Maui.AppView.title: i18n("Folders")
                Maui.AppView.iconName: "folder"
                FoldersView {}
            }
        }
    }

    PixViewer
    {
        id: _pixViewer
        visible: StackView.status === StackView.Active

        Rectangle
        {
            anchors.fill: parent
            visible: _dropArea.containsDrag

            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.95)

            Maui.Rectangle
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                color: "transparent"
                borderColor: Kirigami.Theme.textColor
                solidBorder: false

                Maui.Holder
                {
                    anchors.fill: parent
                    visible: true
                    emoji: "qrc:/img/assets/add-image.svg"
                    emojiSize: Maui.Style.iconSizes.huge
                    title: i18n("Open images")
                    body: i18n("Drag and drop images here")

                }
            }
        }
    }

    footer: SelectionBar
    {
        id: selectionBox
        visible: count > 0 && _stackView.depth === 1
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
        padding: Maui.Style.space.big
        maxListHeight: swipeView.height - Maui.Style.space.medium
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

        onExited:
        {
            if(swipeView.currentIndex === views.viewer)
            {
                swipeView.goBack()
            }
        }

        onEntered:
        {
            if(drag.source)
            {
                return
            }

            swipeView.currentIndex = views.viewer
        }
    }

    Component
    {
        id: _infoDialogComponent
        InfoDialog {}
    }

    Component
    {
        id: tagsDialogComponent
        Maui.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
            composerList.strict: false
        }
    }

    Component
    {
        id: fmDialogComponent
        Maui.FileDialog
        {
            settings.filterType: Maui.FMList.IMAGE
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
            acceptButton.text: i18n("Cancel")
            rejectButton.text: i18n("Accept")

            message: i18np("Are sure you want to delete this file? This action can not be undone.", "Are sure you want to delete these files? This action can not be undone.", urls.length)

            onAccepted: close()
            onRejected:
            {
                Maui.FM.removeFiles(removeDialog.urls)
                selectionBox.clear()
                close()
            }
        }
    }

    Loader { id: dialogLoader }

    /***MODELS****/
    Maui.BaseModel
    {
        id: tagsModel
        list: TagsList
        {
            id: tagsList
        }
    }

    Connections
    {
        target:  Pix.Collection
        function onRefreshViews()
        {
            PIX.refreshViews()
        }

        function onViewPics(pics)
        {
            VIEWER.openExternalPics(pics, 0)
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
        if(Window.window.visibility === Window.FullScreen)
        {
            Window.window.showNormal()
        }else
        {
            Window.window.showFullScreen()
        }

    }
}
