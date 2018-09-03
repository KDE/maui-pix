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

import "view_models"
import "widgets/dialogs/Albums"
import "widgets/dialogs/Tags"

import "widgets/views/Pix.js" as PIX
import "widgets/views/Viewer/Viewer.js" as VIEWER

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Pix")


//    visibility: fullScreen ? ApplicationWindow.FullScreen : ApplicationWindow.Windowed
//    altToolBars: true

    /*READONLY PROPS*/
    readonly property var views : ({
                                       viewer: 0,
                                       gallery: 1,
                                       folders: 2,
                                       albums: 3,
                                       tags: 4,
                                       search: 5
                                   })
    /*PROPS*/

    property int currentView : views.gallery
    property bool fullScreen : false

    property bool selectionMode : false


    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/

    highlightColor : "#00abaa"
    altColor : "#545c6e"
    accentColor: altColor
    altColorText: "#fafafa"
    bgColor: pixViewer.viewerBackgroundColor

    /***************************************************/
    /**************************************************/
    /*************************************************/

    onSearchButtonClicked: currentView =  views.search

//    menuDrawer.bannerImageSource: "qrc:/img/assets/banner.png"
    menuDrawer.actions: [
        Kirigami.Action
        {
            text: "Sources"
            iconName: "love"
            onTriggered: fmDialog.show()
        }
    ]

    headBar.visible: !fullScreen

    headBar.middleContent: PixsBar {}


    ColumnLayout
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

            SearchView
            {
                id: searchView
            }

        }

        Maui.SelectionBar
        {
            id: selectionBox
            Layout.fillWidth : true
            Layout.leftMargin: space.big
            Layout.rightMargin: space.big
            Layout.bottomMargin: space.big
            Layout.topMargin: space.small
            visible: selectionList.count > 0 && currentView !== views.viewer
            onIconClicked: picMenu.showMultiple(selectedPaths)
            onExitClicked: clear()

        }
    }

    PicMenu
    {
        id: picMenu
        onFavClicked: VIEWER.fav(urls)
        onRemoveClicked: PIX.removePic(urls)
        onShareClicked: isAndroid ? Maui.Android.shareDialog(urls) : shareDialog.show(urls)
        onAddClicked: albumsDialog.show(urls)
        onTagsClicked: tagsDialog.show(urls)
        onShowFolderClicked: pix.showInFolder(urls)
    }

    Maui.ShareDialog
    {
        id: shareDialog
    }

    AlbumsDialog
    {
        id: albumsDialog
    }

    TagsDialog
    {
        id: tagsDialog
        forAlbum: false
        onTagsAdded: addTagsToPic(urls, tags)
    }

    Maui.FileDialog
    {
        id: fmDialog
        multipleSelection: false
        onlyDirs: true
    }

    Connections
    {
        target: pix

        onRefreshViews: PIX.refreshViews()
        onViewPics: VIEWER.openExternalPics(pics, 0)
    }

    Connections
    {
        target: tag
        onTagged: tagsView.populate()
    }

//    Component.onCompleted:
//    {
//        if(isAndroid)
//            switchColorScheme(colorScheme.Dark)
//    }
}
