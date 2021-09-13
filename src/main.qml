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

import QtQuick.Window 2.13
import Qt.labs.settings 1.0

import org.kde.kirigami 2.8 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.imagetools 1.3 as IT

import org.maui.pix 1.0 as Pix

import "widgets"
import "widgets/views/Folders"
import "widgets/views/Gallery"
import "widgets/views/Tags"
import "widgets/views/Viewer"
import "view_models"

import "widgets/views/Viewer/Viewer.js" as VIEWER

Maui.ApplicationWindow
{
    id: root
    title: _pixViewer.currentPic.title || Maui.App.displayName
    headBar.visible:false

    property alias dialog : dialogLoader.item

    /*READONLY PROPS*/
    readonly property var views : ({ gallery: 0,
                                       tags: 1,
                                       folders: 2 })
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

    StackView
    {
        id: _stackView
        anchors.fill: parent
        focus: true

        initialItem: Maui.AppViews
        {
            id: swipeView
            altHeader: Kirigami.Settings.isMobile
            interactive: Kirigami.Settings.isMobile
            floatingFooter: true
            flickable: swipeView.currentItem.item.flickable || swipeView.currentItem.flickable
            showCSDControls: true

            headBar.leftContent: Maui.ToolButtonMenu
            {
                icon.name: "application-menu"

                MenuItem
                {
                    text: i18n("Open")
                    icon.name: "folder-open"
                    onTriggered:
                    {
                        dialogLoader.sourceComponent= fmDialogComponent
                        dialog.mode = dialog.modes.OPEN
                        dialog.settings.filterType= FB.FMList.IMAGE
                        dialog.settings.onlyDirs= false
                        dialog.callback = function(paths)
                        {
                            console.log("OPEN THIS PATHS", paths)
                            Pix.Collection.openPics(paths)
                        };
                        dialog.open()
                    }
                }

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

                MenuItem
                {
                    text: i18n("About")
                    icon.name: "documentinfo"
                    onTriggered: root.about()
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
            acceptButton.text: i18n("Cancel")
            rejectButton.text: i18n("Accept")

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

    /***MODELS****/
    Maui.BaseModel
    {
        id: tagsModel
        list: FB.TagsListModel
        {
            id: tagsList
        }
    }

    Connections
    {
        target:  Pix.Collection

        function onViewPics(pics)
        {
            VIEWER.openExternalPics(pics, 0)
        }
    }

    Component.onCompleted:
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor(headBar.Kirigami.Theme.backgroundColor, false)
            Maui.Android.navBarColor(headBar.visible ? headBar.Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor, false)

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
