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
import Qt.labs.platform 1.0 as Labs
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

    Maui.Style.styleType: Maui.Handy.isAndroid ? (browserSettings.darkMode ? Maui.Style.Dark : Maui.Style.Light) : undefined
    property alias dialog : dialogLoader.item
    property alias selectionBox : _selectionBar
    property alias mainGalleryList : _mainGalleryListLoader.item

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
        property bool showLabels : false
        property bool fitPreviews : false
        property bool autoReload: true
        property int previewSize : previewSizes.medium
        property string sortBy : "modified"
        property int sortOrder: Qt.DescendingOrder
        property bool darkMode : true
        property bool gpsTags : false
        property bool showSidebar : !Maui.Handy.isMobile
    }

    Settings
    {
        id: viewerSettings
        property bool tagBarVisible : true
        property bool previewBarVisible : false
    }

    Loader
    {
        id: _mainGalleryListLoader
        asynchronous: true
        active: _collectionView.visible || item
        sourceComponent: Pix.GalleryList
        {
            autoReload: browserSettings.autoReload
            urls: Pix.Collection.sources
            recursive: true
            activeGeolocationTags: browserSettings.gpsTags
        }
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent

        initialItem: initModule === "viewer" ? _pixViewer : _collectionView

        Maui.SideBarView
        {
            id: _collectionView
            visible: StackView.status === StackView.Active

            sideBar.enabled: browserSettings.showSidebar

            sideBar.content: Pane
            {
                anchors.fill: parent

                background: null
                padding: 0

                Maui.ListBrowser
                {
                    anchors.fill: parent

                    flickable.topMargin: Maui.Style.space.medium
                    flickable.bottomMargin: Maui.Style.space.medium
                    flickable.header: GridLayout
                    {
                        width: Math.min(parent.width, 180)
                        rows: 3
                        columns: 3
                        columnSpacing: Maui.Style.space.small
                        rowSpacing: Maui.Style.space.small


                        Maui.GridBrowserDelegate
                        {
                            isCurrentItem: swipeView.currentIndex === views.tags && swipeView.currentItem.item.currentTag === "fav"
                            Layout.columnSpan: 2

                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            iconSource: "love"
                            labelsVisible: false
                            tooltipText: i18n("Favorites")
                            flat: false

                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true

                            onClicked: openTag("fav")
                        }

                        Maui.GridBrowserDelegate
                        {
                            isCurrentItem: swipeView.currentIndex === views.folders

                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            iconSource: "folder"
                            labelsVisible: false
                            tooltipText: i18n("Folders")
                            flat: false

                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true

                            onClicked: swipeView.currentIndex = views.folders
                        }

                        Maui.GridBrowserDelegate
                        {
                            isCurrentItem: swipeView.currentIndex === views.recent

                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            iconSource: "view-media-recent"
                            labelsVisible: false
                            tooltipText: "Recent"
                            flat: false

                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true

                            onClicked: swipeView.currentIndex = views.recent
                        }

                        Maui.GridBrowserDelegate
                        {
                            isCurrentItem: swipeView.currentIndex === views.gallery
                            Layout.columnSpan: 2

                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            iconSource: "viewimage"
                            labelsVisible: false
                            tooltipText: i18n("Collection")
                            flat: false

                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true

                            onClicked:
                            {
                                _foldersViewLoader.item.pop()

                                swipeView.currentIndex = views.gallery



                            }
                        }

                        Maui.GridBrowserDelegate
                        {
                            readonly property string url : Labs.StandardPaths.writableLocation(Labs.StandardPaths.DownloadLocation)
                            isCurrentItem: swipeView.currentIndex === views.folders && swipeView.currentItem.item.currentFolder === url

                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            iconSource: "folder-downloads"
                            labelsVisible: false
                            tooltipText: "Downloads"
                            flat: false

                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true

                            onClicked:
                            {
                                swipeView.currentIndex = views.folders
                                openFolder(url)
                            }
                        }

                        Maui.GridBrowserDelegate
                        {
                            isCurrentItem: swipeView.currentIndex === model.viewIndex

                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            iconSource: model.icon
                            labelsVisible: false
                            tooltipText: model.label
                            flat: false

                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true

                            onClicked: swipeView.currentIndex = model.viewIndex
                        }


                        Maui.GridBrowserDelegate
                        {
                            isCurrentItem: swipeView.currentIndex === model.viewIndex

                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            iconSource: model.icon
                            labelsVisible: false
                            tooltipText: model.label
                            flat: false

                            iconSizeHint: Maui.Style.iconSize
                            template.isMask: true

                            onClicked: swipeView.currentIndex = model.viewIndex
                        }

                    }

                    model: Maui.BaseModel
                    {

                        list: Pix.TagsList
                        {
                        }

                    }

                    delegate: Maui.ListDelegate
                    {
                        isCurrentItem: model.tag === swipeView.currentItem.item.currentTag
                        width: ListView.view.width

                        iconSize: Maui.Style.iconSize
                        label: model.tag
                        iconName: model.icon +  (Qt.platform.os == "android" || Qt.platform.os == "osx" ? ("-sidebar") : "")
                        iconVisible: true
                        template.isMask: iconSize <= Maui.Style.iconSizes.medium
                        onClicked: openTag(model.tag)
                    }

                    section.property: "type"
                    section.criteria: ViewSection.FullString
                    section.delegate: Maui.LabelDelegate
                    {
                        width: ListView.view.width
                        label: i18n("Tags")
                        isSection: true
                        //                height: Maui.Style.toolBarHeightAlt
                    }
                }

            }

            Maui.AppViews
            {
                id: swipeView
                anchors.fill: parent
                currentIndex: initModule === "folder" ? views.folders : views.folders
                actionGroup: !browserSettings.showSidebar

                altHeader: Maui.Handy.isMobile
                floatingFooter: true
                flickable: swipeView.currentItem.item.flickable || swipeView.currentItem.flickable
                showCSDControls:  initModule !== "viewer"
                //            headBar.forceCenterMiddleContent: root.isWide

                headBar.leftContent: [

                    ToolButton
                    {
                        icon.name: _collectionView.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
                        onClicked: _collectionView.sideBar.toggle()
                        checked: _collectionView.sideBar.visible
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("Toggle sidebar")
                    },

                    Loader
                    {
                        asynchronous: true
                        sourceComponent: Loader
                        {
                            asynchronous: true
                            sourceComponent: Maui.ToolButtonMenu
                            {
                                icon.name: "application-menu"

                                MenuItem
                                {
                                    text: i18n("Open")
                                    icon.name: "folder-open"
                                    onTriggered: openFileDialog()

                                }

                                MenuItem
                                {
                                    text: i18n("Settings")
                                    icon.name: "settings-configure"
                                    onTriggered: openSettingsDialog()
                                }

                                MenuItem
                                {
                                    text: i18n("About")
                                    icon.name: "documentinfo"
                                    onTriggered: root.about()
                                }
                            }
                        }
                    },

                    ToolButton
                    {
                        visible: _pixViewer.viewer.count
                        icon.name: "quickview"
                        text: _pixViewer.viewer.count
                        onClicked: toggleViewer()
                    }
                ]

                footer: SelectionBar
                {
                    id: _selectionBar
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)

                    maxListHeight: swipeView.height - Maui.Style.space.medium
                    display: ToolButton.IconOnly
                }


                Maui.AppViewLoader
                {
                    Maui.AppView.title: i18n("Gallery")
                    Maui.AppView.iconName: "image-multiple"

                    GalleryView
                    {
                        list: mainGalleryList
                    }
                }

                Maui.AppViewLoader
                {
                    id: _tagsViewLoader
                    Maui.AppView.title: i18n("Tags")
                    Maui.AppView.iconName: "tag"

                    property string pendingTag
                    TagsView
                    {
                        Component.onCompleted:
                        {
                            if(_tagsViewLoader.pendingTag)
                                populateGrid(_tagsViewLoader.pendingTag)
                        }
                    }
                }

                Maui.AppViewLoader
                {
                    id: _foldersViewLoader
                    Maui.AppView.title: i18n("Folders")
                    Maui.AppView.iconName: "folder"
                    property string pendingFolder : initModule === "folder" ? initData : ""

                    FoldersView {}
                }
            }

        }

        PixViewer
        {
            id: _pixViewer
            visible: StackView.status === StackView.Active
            showCSDControls:  initModule === "viewer"

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
                _stackView.replace(_pixViewer, _collectionView)

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

    function openFileDialog()
    {
        dialogLoader.sourceComponent= fmDialogComponent
        dialog.mode = dialog.modes.OPEN
        dialog.settings.filterType= FB.FMList.IMAGE
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

    function openTag(tag)
    {
        if( swipeView.currentIndex === views.tags)
        {
            swipeView.currentItem.item.populateGrid(tag)
            swipeView.currentItem.refreshPics()
        }else
        {
            _tagsViewLoader.pendingTag = tag
            swipeView.currentIndex = views.tags
        }
    }

    function openFolder(url)
    {
        if(_foldersViewLoader.item)
        {
            _foldersViewLoader.item.openFolder(url)
        }else
        {
            _foldersViewLoader.pendingFolder = url
        }
        swipeView.currentIndex = views.folders
    }
}
