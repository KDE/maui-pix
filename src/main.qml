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

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.pix 1.0 as Pix

import "widgets"
import "widgets/views/Folders"
import "widgets/views/Gallery"
import "widgets/views/Tags"
import "widgets/views/Viewer"
import "view_models"

import "widgets/views/Pix.js" as PIX
import "widgets/views/Viewer/Viewer.js" as VIEWER

import TagsModel 1.0
import TagsList 1.0

Maui.ApplicationWindow
{
    id: root
    title: i18n("Pix")
    //    visibility: fullScreen ? ApplicationWindow.FullScreen : ApplicationWindow.Windowed

    property alias dialog : dialogLoader.item
    property alias pixViewer : _pixViewerLoader.item

    /*READONLY PROPS*/
    readonly property var views : ({ viewer: 0,
                                       gallery: 1,
                                       tags: 2,
                                       folders: 3 })
    /*PROPS*/
    property bool showLabels : Maui.FM.loadSettings("SHOW_LABELS", "GRID", !Kirigami.Settings.isMobile) === "true" ? true : false
    property bool fitPreviews : Maui.FM.loadSettings("PREVIEWS_FIT", "GRID", true) === "false" ?  false : true
    property bool autoScan: Maui.FM.loadSettings("AUTOSCAN", "GRID", true) === "false" ?  false : true

    property bool autoReload: Maui.FM.loadSettings("AUTORELOAD", "GRID", true) === "false" ?  false : true

    readonly property bool fullScreen : root.visibility === Window.FullScreen
    property bool selectionMode : false
    property int previewSize : Maui.FM.loadSettings("PREVIEWSIZE", "UI", Maui.Style.iconSizes.huge * 1.5)

    flickable: swipeView.currentItem.item ? swipeView.currentItem.item.flickable || null : swipeView.currentItem.flickable || null

    mainMenu: [

        MenuSeparator{},

        MenuItem
        {
            text: i18n("Open")
            icon.name: "folder-open"
            onTriggered:
            {
                dialogLoader.sourceComponent= fmDialogComponent
                dialog.mode = dialog.modes.OPEN
                dialog.settings.filterType= Maui.FMList.IMAGE
                dialog.settings.onlyDirs= false
                dialog.show(function(paths)
                {
                    console.log("OPEN THIS PATHS", paths)
                    Pix.Collection.openPics(paths)
                });
            }
        },

        MenuSeparator{},

        MenuItem
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

    headBar.visible: !fullScreen

    floatingHeader: swipeView.currentIndex === views.viewer ? !pixViewer.editing : false
    autoHideHeader: swipeView.currentIndex === views.viewer
    headerPositioning: ListView.InlineHeader

    headBar.rightContent: ToolButton
    {
        visible: Maui.Handy.isTouch
        icon.name: "item-select"
        onClicked:
        {
            selectionMode = !selectionMode
            if(selectionMode)
                swipeView.currentIndex = views.gallery
        }

        checkable: true
        checked: selectionMode
    }

    MauiLab.AppViews
    {
        id: swipeView
        anchors.fill: parent
        Component.onCompleted: swipeView.currentIndex = views.gallery

        MauiLab.AppViewLoader
        {
            id: _pixViewerLoader
            MauiLab.AppView.title: i18n("Viewer")
            MauiLab.AppView.iconName: "document-preview-archive"
            //                Kirigami.Theme.inherit: false
            //                Kirigami.Theme.backgroundColor: "#333"
            //                Kirigami.Theme.textColor: "#fafafa"

            PixViewer
            {
                Rectangle
                {
                    anchors.fill: parent
                    visible: _dropArea.containsDrag

                    color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.95)

                    MauiLab.Rectangle
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
        }

        GalleryView
        {
            id: _galleryView
            MauiLab.AppView.title: i18n("Gallery")
            MauiLab.AppView.iconName: "image-multiple"
        }


        MauiLab.AppViewLoader
        {
            MauiLab.AppView.title: i18n("Tags")
            MauiLab.AppView.iconName: "tag"
            TagsView {}
        }

        MauiLab.AppViewLoader
        {
            MauiLab.AppView.title: i18n("Folders")
            MauiLab.AppView.iconName: "image-folder-view"
            FoldersView {}
        }
    }

    footer: SelectionBar
    {
        id: selectionBox
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
        id: shareDialogComponent
        MauiLab.ShareDialog {}
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
            mode: modes.SAVE
            settings.filterType: Maui.FMList.IMAGE
            settings.onlyDirs: false
        }
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog {}
    }

    Maui.Dialog
    {
        id: removeDialog

        title: i18n("Delete files?")
        acceptButton.text: i18n("Accept")
        rejectButton.text: i18n("Cancel")
        message: i18n("Are sure you want to delete %1 files").arg(selectionBox.count)
        page.padding: Maui.Style.space.huge
        onRejected: close()
        onAccepted:
        {
            for(var url of selectionBox.uris)
                Maui.FM.removeFile(url)
            selectionBox.clear()
            close()
        }
    }

    Loader { id: dialogLoader }

    /***MODELS****/
    TagsModel
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
        onRefreshViews: PIX.refreshViews()
        onViewPics: VIEWER.openExternalPics(pics, 0)
    }

    function setPreviewSize(size)
    {
        root.previewSize = size
        Maui.FM.saveSettings("PREVIEWSIZE",  root.previewSize, "UI")
    }

    function getFileInfo(url)
    {
        dialogLoader.sourceComponent= _infoDialogComponent
        dialog.url = url
        dialog.open()
    }
}
