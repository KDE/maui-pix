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
import org.kde.maui 1.0 as Maui

import "widgets"
import "widgets/views/Albums"
import "widgets/views/Folders"
import "widgets/views/Gallery"
import "widgets/views/Settings"
import "widgets/views/Tags"
import "widgets/views/Viewer"
import "widgets/views/Search"

import "view_models"
import "widgets/dialogs/share"
import "widgets/dialogs/Albums"
import "widgets/dialogs/Tags"

import "widgets/custom/SelectionBox"

import "widgets/views/Pix.js" as PIX
import "widgets/views/Viewer/Viewer.js" as VIEWER

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Pix")

    visibility: fullScreen ? ApplicationWindow.FullScreen : ApplicationWindow.Windowed


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
    property bool fitPreviews : pix.loadSettings("PREVIEWS_FIT", "PIX", false) === "false" ?  false : true


    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/

    property string pixColor : pix.pixColor()

    /***************************************************/
    /**************************************************/
    /*************************************************/

    onSearchButtonClicked: currentView =  views.search

    menuDrawer.bannerImageSource: "qrc:/img/assets/banner.png"

    headBar.middleContent: PixsBar
    {
        visible: !fullScreen

        onViewerViewClicked: currentView = views.viewer
        onGalleryViewClicked: currentView = views.gallery
        onFoldersViewClicked: currentView = views.folders
        onAlbumsViewClicked: currentView = views.albums
        onTagsViewClicked: currentView = views.tags
    }

    footBar.leftContent: Maui.ToolButton
    {
        iconName: "document-share"
        onClicked: isAndroid ? android.shareDialog(pixViewer.currentPic.url) :
                               shareDialog.show(pixViewer.currentPic.url)
    }

    footBar.middleContent: PixFooter
    {
        id: pixFooter

    }

    footBar.rightContent : Maui.ToolButton
    {
        iconName: fullScreen? "window-close" : "view-fullscreen"
        onClicked: fullScreen = !fullScreen

    }

    footBar.visible: !pixViewer.holder.visible && currentView === views.viewer


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

        SelectionBox
        {
            id: selectionBox
            Layout.fillWidth : true
            Layout.leftMargin: contentMargins*2
            Layout.rightMargin: contentMargins*2
            Layout.bottomMargin: contentMargins
            Layout.topMargin: space.small
            visible: selectionList.count > 0 && currentView !== views.viewer
        }
    }


    PicMenu
    {
        id: picMenu
        onFavClicked: VIEWER.fav(url)
        onRemoveClicked: PIX.removePic(url)
        onShareClicked: isAndroid ? android.shareDialog(url) : shareDialog.show(url)
        onAddClicked: albumsDialog.show(url)
        onTagsClicked: tagsDialog.show(url)
        onShowFolderClicked: pix.showInFolder(url)
    }

    ShareDialog
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
        onTagsAdded: addTagsToPic(url, tags)
    }

    Connections
    {
        target: pix

        onRefreshViews: PIX.refreshViews()
        onViewPics: VIEWER.open(pics, 0)
    }

    Component.onCompleted: if(isAndroid) android.statusbarColor(backgroundColor, textColor)
}
