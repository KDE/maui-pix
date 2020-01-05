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

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "widgets"
import "widgets/views/Albums"
import "widgets/views/Folders"
import "widgets/views/Gallery"
import "widgets/views/Tags"
import "widgets/views/Viewer"
import "widgets/views/Search"
import "widgets/views/Cloud"
import "widgets/views/Store"

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
    //    altToolBars: true
    Maui.App.description: qsTr("Pix is a convergent gallery manager and image viewer. Supports GNU Linux, Android and Windows.")
    Maui.App.iconName: "qrc:/img/assets/pix.svg"

    property alias dialog : dialogLoader.item
    /*READONLY PROPS*/
    readonly property var views : ({
                                       viewer: 0,
                                       gallery: 1,
                                       tags: 2,
                                       folders: 3,
                                       //                                       cloud: 5,
                                       //                                       store: 6,
                                       search: 4
                                   })
    /*PROPS*/

    property bool showLabels : Maui.FM.loadSettings("SHOW_LABELS", "GRID", !Kirigami.Settings.isMobile) === "true" ? true : false
    property bool fitPreviews : Maui.FM.loadSettings("PREVIEWS_FIT", "GRID", false) === "false" ?  false : true


    property bool fullScreen : false
    property bool selectionMode : false
    onSearchButtonClicked: _actionGroup.currentIndex =  views.search

    background: Rectangle
    {
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
    }

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

        MenuItem
        {
            text: qsTr("Sources")
            icon.name: "folder-add"
            onTriggered:
            {
                dialogLoader.sourceComponent = sourcesDialogComponent
                dialog.open()
            }
        },

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
    headBar.spacing: Maui.Style.space.big
    headBar.middleContent: Maui.ActionGroup
    {
        id: _actionGroup
        Layout.fillHeight: true
        Layout.minimumWidth: implicitWidth
        currentIndex : swipeView.currentIndex
        onCurrentIndexChanged: swipeView.currentIndex = currentIndex

        Action
        {
            text: qsTr("Viewer")
            icon.name: "document-preview-archive"
        }

        Action
        {
            text: qsTr("Gallery")
            icon.name: "image-multiple"
        }

        Action
        {
            text: qsTr("Tags")
            icon.name: "tag"
        }

        Action
        {
            text: qsTr("Folders")
            icon.name: "image-folder-view"
        }
    }

    ColumnLayout
    {
        anchors.fill: parent

        SwipeView
        {
            id: swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true
            interactive: Kirigami.Settings.isMobile
            currentIndex: _actionGroup.currentIndex
            onCurrentIndexChanged: _actionGroup.currentIndex = currentIndex
            Component.onCompleted: swipeView.currentIndex = views.gallery

            PixViewer
            {
                id: pixViewer
            }

            GalleryView
            {
                id: galleryView
            }

            TagsView
            {
                id: tagsView
            }

            FoldersView
            {
                id: foldersView
            }

            SearchView
            {
                id: searchView
            }

        }

        SelectionBar
        {
            id: selectionBox
            Layout.maximumWidth: 500
            Layout.minimumWidth: 100
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            Layout.margins: Maui.Style.space.big
            Layout.topMargin: Maui.Style.space.small
            Layout.bottomMargin: Maui.Style.space.big
        }
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

    Component
    {
        id: shareDialogComponent
        Maui.ShareDialog
        {
            id: shareDialog
        }
    }

    Component
    {
        id: tagsDialogComponent
        Maui.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
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
                    onClicked: console.log(Maui.Handy.isTouch)
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

        Maui.Dialog
        {
            maxHeight: 300
            maxWidth: 300
            defaultButtons: false

            Kirigami.ScrollablePage
            {
                anchors.fill: parent
                Kirigami.FormLayout
                {
                    width: parent.width
                    anchors.centerIn: parent

                    Item
                    {
                        Kirigami.FormData.isSection: true
                        Kirigami.FormData.label: qsTr("Collection")
                    }

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

                    Item
                    {
                        Kirigami.FormData.isSection: true
                        Kirigami.FormData.label: qsTr("Viewer")
                    }

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
}
