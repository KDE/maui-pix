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

import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

import "widgets"
import "widgets/views/Folders"
import "widgets/views/Gallery"
import "widgets/views/Tags"
import "widgets/views/Viewer"
//import "widgets/views/Cloud"
//import "widgets/views/Store"

import "view_models"

import "widgets/views/Pix.js" as PIX
import "widgets/views/Viewer/Viewer.js" as VIEWER
import "db/Query.js" as Q

import TagsModel 1.0
import TagsList 1.0
import org.maui.pix 1.0 as Pix

//import SyncingModel 1.0
//import SyncingList 1.0
//import StoreList 1.0

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Pix")
    //    visibility: fullScreen ? ApplicationWindow.FullScreen : ApplicationWindow.Windowed
    Maui.App.description: qsTr("Pix is a convergent gallery manager and image viewer. Supports GNU Linux, Android and Windows.")
    Maui.App.iconName: "qrc:/img/assets/pix.svg"
    Maui.App.handleAccounts: false
    Maui.App.enableCSD: true

    property alias dialog : dialogLoader.item
    property alias pixViewer : _pixViewerLoader.item

    /*READONLY PROPS*/
    readonly property var views : ({ viewer: 0,
                                       gallery: 1,
                                       tags: 2,
                                       folders: 3 })
    /*PROPS*/
    property bool showLabels : Maui.FM.loadSettings("SHOW_LABELS", "GRID", !Kirigami.Settings.isMobile) === "true" ? true : false
    property bool fitPreviews : Maui.FM.loadSettings("PREVIEWS_FIT", "GRID", false) === "false" ?  false : true

    readonly property bool fullScreen : root.visibility === Window.FullScreen
    property bool selectionMode : false
    property int previewSize : Maui.FM.loadSettings("PREVIEWSIZE", "UI", Maui.Style.iconSizes.huge * 1.5)

    flickable: swipeView.currentItem.item.flickable || null

    mainMenu: [

        MenuSeparator{},

        MenuItem
        {
            text: qsTr("Open")
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

        //        MenuItem
        //        {
        //            text: qsTr("Sources")
        //            icon.name: "folder-add"
        //            onTriggered:
        //            {
        //                dialogLoader.sourceComponent = sourcesDialogComponent
        //                dialog.open()
        //            }
        //        },

        MenuItem
        {
            text: qsTr("Settings")
            icon.name: "settings-configure"
            onTriggered:
            {
                dialogLoader.sourceComponent = _settingsDialogComponent
                dialog.open()
            }
        }
    ]

    headBar.visible: !fullScreen

    floatingHeader: swipeView.currentIndex === views.viewer
    autoHideHeader: swipeView.currentIndex === views.viewer

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
            MauiLab.AppView.title: qsTr("Viewer")
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
                            title: qsTr("Open images")
                            body: qsTr("Drag and drop images here")
                        }
                    }
                }
            }
        }

        MauiLab.AppViewLoader
        {
            MauiLab.AppView.title: qsTr("Gallery")
            MauiLab.AppView.iconName: "image-multiple"
            Kirigami.Theme.highlightColor: "red"
            Kirigami.Theme.inherit: false

            GalleryView {}
        }

        MauiLab.AppViewLoader
        {
            MauiLab.AppView.title: qsTr("Tags")
            MauiLab.AppView.iconName: "tag"
            TagsView {}
        }

        MauiLab.AppViewLoader
        {
            MauiLab.AppView.title: qsTr("Folders")
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


    /*** Components ***/

    //    Component
    //    {
    //        id: _cloudViewComponent
    //        CloudView
    //        {
    //            anchors.fill : parent
    //        }
    //    }

    //    Component
    //    {
    //        id: _storeViewComponent

    //        Maui.Store
    //        {
    //            anchors.fill : parent
    //            detailsView: true
    //            list.category: StoreList.WALLPAPERS
    //            list.provider: StoreList.KDELOOK
    //        }
    //    }

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
        id: sourcesDialogComponent
        Maui.Dialog
        {
            maxHeight: 500
            maxWidth: 500

            page.title: qsTr("Sources")

            headBar.rightContent: [
                ToolButton
                {
                    icon.name: "list-add"
                    onClicked:
                    {

                    }
                },

                ToolButton
                {
                    icon.name: "list-remove"
                }
            ]

            ListView
            {
                id: _listView
                clip: true
                anchors.fill: parent
                delegate: Maui.ListDelegate
                {
                    id: _delegate
                    label: model.url

                    Connections
                    {
                        target: _delegate
                        onClicked: _listView.currentIndex = index
                    }
                }

                model: ListModel{}
            }

            Component.onCompleted:
            {
                const items = Pix.DB.get("select * from sources")
                for(var i in items)
                    _listView.model.append(items[i]);
            }
        }
    }

    Component
    {
        id: _settingsDialogComponent

        MauiLab.SettingsDialog
        {
            MauiLab.SettingsSection
            {
                title: qsTr("Collection")
                description: qsTr("Configure the app plugins and behavior.")

                Switch
                {
                    //                        visible: false //TODO to fix
                    icon.name: "image-preview"
                    checkable: true
                    checked: root.fitPreviews
                    Kirigami.FormData.label: qsTr("Fit previews")
                    onToggled:
                    {
                        root.fitPreviews = !root.fitPreviews
                        Maui.FM.saveSettings("PREVIEWS_FIT", fitPreviews, "GRID")
                    }
                }

                Switch
                {
                    Kirigami.FormData.label: qsTr("Show labels")
                    checkable: true
                    checked: root.showLabels
                    onToggled:
                    {
                        root.showLabels = !root.showLabels
                        Maui.FM.saveSettings("SHOW_LABELS", showLabels, "GRID")
                    }
                }

                Maui.ToolActions
                {
                    id: _gridIconSizesGroup
                    Kirigami.FormData.label: qsTr("Preview Size")
                    Layout.fillWidth: true
                    expanded: true
                    autoExclusive: true
                    display: ToolButton.TextOnly

                    Action
                    {
                        text: qsTr("S")
                        onTriggered: setPreviewSize(Maui.Style.iconSizes.huge * 1.2)
                    }

                    Action
                    {
                        text: qsTr("M")
                        onTriggered: setPreviewSize(Maui.Style.iconSizes.huge * 1.5)
                    }

                    Action
                    {
                        text: qsTr("X")
                        onTriggered: setPreviewSize(Maui.Style.iconSizes.huge * 1.8 )
                    }

                    Action
                    {
                        text: qsTr("XL")
                        onTriggered: setPreviewSize(Maui.Style.iconSizes.enormous * 1.2)
                    }
                }
            }

            MauiLab.SettingsSection
            {
                title: qsTr("Viewer")

                Switch
                {
                    Kirigami.FormData.label: qsTr("Show tag bar")
                    checkable: true
                    checked: pixViewer.tagBarVisible
                    onToggled: pixViewer.toogleTagbar()
                }

                Switch
                {
                    Kirigami.FormData.label: qsTr("Show preview bar")
                    checkable: true
                    checked: pixViewer.roll.visible
                    onToggled: pixViewer.tooglePreviewBar()
                }
            }
        }
    }

    Maui.Dialog
    {
        id: removeDialog

        title: qsTr("Delete files?")
        acceptButton.text: qsTr("Accept")
        rejectButton.text: qsTr("Cancel")
        message: qsTr("Are sure you want to delete %1 files").arg(selectionBox.count)
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

    Loader
    {
        id: dialogLoader
    }

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
}
