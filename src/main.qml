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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "widgets"
import "widgets/views/Albums"
import "widgets/views/Folders"
import "widgets/views/Gallery"
import "widgets/views/Settings"
import "widgets/views/Tags"
import "widgets/views/Viewer"
import "widgets/views/Search"
import "widgets/views/Cloud"

import "view_models"
import "widgets/dialogs/Albums"
import "widgets/dialogs/Tags"

import "widgets/views/Pix.js" as PIX
import "widgets/views/Viewer/Viewer.js" as VIEWER
import "db/Query.js" as Q

import PixModel 1.0
import AlbumsList 1.0

import TagsModel 1.0
import TagsList 1.0

import SyncingModel 1.0
import SyncingList 1.0

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Pix")

    //    visibility: fullScreen ? ApplicationWindow.FullScreen : ApplicationWindow.Windowed
    //    altToolBars: true
    about.appDescription: qsTr("Pix is an image gallery manager made for Maui. Pix is a convergent and multiplatform app that works under Android and GNU Linux distros.")
    about.appIcon: "qrc:/img/assets/pix.svg"

    property alias dialog : dialogLoader.item
    /*READONLY PROPS*/
    readonly property var views : ({
                                       viewer: 0,
                                       gallery: 1,
                                       folders: 2,
                                       albums: 3,
                                       tags: 4,
                                       cloud: 5,
                                       search: 6
                                   })
    /*PROPS*/

    property int currentView : views.gallery
    property bool fullScreen : false

    property bool selectionMode : false
    property alias currentAccount: _accountCombobox.currentText

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/

    highlightColor : "#00abaa"
    altColor : "#2e2f30" // "#545c6e"
    accentColor: altColor
    altColorText: "#fafafa"
    colorSchemeName: "pix"
    bgColor: pixViewer.viewerBackgroundColor
    headBarBGColor: currentView === views.viewer ? accentColor : Maui.Style.backgroundColor
    headBarFGColor: currentView === views.viewer ? altColorText : Maui.Style.textColor
    backgroundColor:  currentView === views.viewer ? "#3c3e3f" : Maui.Style.backgroundColor
    viewBackgroundColor: currentView === views.viewer ? backgroundColor : Maui.Style.viewBackgroundColor
    textColor: headBarFGColor

    /***************************************************/
    /**************************************************/
    /*************************************************/

    onSearchButtonClicked: currentView =  views.search

    //    menuDrawer.bannerImageSource: "qrc:/img/assets/banner.png"
    mainMenu: [
        Maui.MenuItem
        {
            text: "Sources"
            onTriggered:
            {
                dialogLoader.sourceComponent= fmDialogComponent
                dialog.show()
            }
        }
    ]

    headBar.visible: !fullScreen
    headBar.leftContent:[
        Maui.ComboBox
        {
            id: _accountCombobox
            visible: count > 1
            textRole: "user"
            flat: true
            model: accounts.model
            iconButton.iconName: "list-add-user"
        }
    ]

    headBar.middleContent: [
        Maui.ToolButton
        {
            //            text: qsTr("Viewer")
            visible: !pixViewer.holder.visible
            iconColor: currentView === views.viewer ? highlightColor : headBarFGColor
            iconName: "image"
            onClicked: currentView = views.viewer
        },

        Maui.ToolButton
        {
            //            text: qsTr("Gallery")
            iconColor: currentView === views.gallery? highlightColor : headBarFGColor
            iconName: "image-multiple"
            onClicked: currentView = views.gallery
        },

        Maui.ToolButton
        {
            //            text: qsTr("Folders")
            iconColor: currentView === views.folders? highlightColor : headBarFGColor
            iconName: "image-folder-view"
            onClicked: currentView = views.folders
        },

        Maui.ToolButton
        {
            //            text: qsTr("Albums")
            iconColor: currentView === views.albums? highlightColor : headBarFGColor
            iconName: "image-frames"
            onClicked: currentView = views.albums
        },

        Maui.ToolButton
        {
            //            text: qsTr("Tags")
            iconColor: currentView === views.tags? highlightColor : headBarFGColor
            iconName: "tag"
            onClicked: currentView = views.tags
        },

        Maui.ToolButton
        {
            //            text: qsTr("Cloud")
            iconColor: currentView === views.cloud? highlightColor : headBarFGColor
            iconName: "folder-cloud"
            onClicked: currentView = views.cloud
        }
    ]


    content: ColumnLayout
    {
        id: mainPage
        anchors.fill: parent

        SwipeView
        {
            id: swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true
            interactive: isMobile
            currentIndex: currentView

            onCurrentIndexChanged: currentView = currentIndex

            PixViewer
            {
                id: pixViewer
            }

            GalleryView
            {
                id: galleryView
            }

            FoldersView
            {
                id: foldersView
            }

            AlbumsView
            {
                id: albumsView
            }

            TagsView
            {
                id: tagsView
            }

            CloudView
            {
                id: cloudView
            }

            SearchView
            {
                id: searchView
            }
        }

        SelectionBar
        {
            id: selectionBox
            Layout.fillWidth : true
            Layout.leftMargin: space.big
            Layout.rightMargin: space.big
            Layout.bottomMargin: space.big
            Layout.topMargin: space.small
        }
    }

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
        id: albumsDialogComponent
        AlbumsDialog
        {
            id: albumsDialog
        }
    }

    Component
    {
        id: tagsDialogComponent
        TagsDialog
        {
            id: tagsDialog
            forAlbum: false
            onTagsAdded: addTagsToPic(urls, tags)
        }
    }

    Component
    {
        id: fmDialogComponent
        Maui.FileDialog
        {
            id: fmDialog
            onlyDirs: true
            mode: modes.SAVE
        }
    }

    Loader
    {
        id: dialogLoader
    }

    /***MODELS****/
    PixModel
    {
        id: albumsModel
        list: albumsList
    }

    AlbumsList
    {
        id: albumsList
        query: Q.Query.allAlbums
    }

    TagsModel
    {
        id: tagsModel
        list: tagsList
    }

    TagsList
    {
        id: tagsList
    }

    Connections
    {
        target: pix
        onRefreshViews: PIX.refreshViews()
        onViewPics: VIEWER.openExternalPics(pics, 0)
    }
}
