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
import org.kde.kirigami 2.0 as Kirigami
import QtQuick.Controls.Material 2.1
import QtQuick.Window 2.0
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

Kirigami.ApplicationWindow
{
    id: root
    visible: true
    title: qsTr("Pix")
    width: Screen.width * (isMobile ? 1 : 0.5)
    //    height: Screen.height * (isMobile ? 1 : 0.4)
    visibility: fullScreen ? ApplicationWindow.FullScreen : ApplicationWindow.Windowed

    /* FOR MATERIAL*/
    Material.theme: Material.Light
    Material.accent: pixColor
    Material.background: viewBackgroundColor
    Material.primary: backgroundColor
    Material.foreground: textColor

    /*READONLY PROPS*/

    readonly property bool isMobile : Kirigami.Settings.isMobile
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

    /*UI PROPS*/

    readonly property int contentMargins: isMobile ? 8 : 10
    readonly property int defaultFontSize: Kirigami.Theme.defaultFont.pointSize
    readonly property var fontSizes: ({
                                          tiny: defaultFontSize - 2,
                                          small: defaultFontSize -1,
                                          default: defaultFontSize,
                                          big: defaultFontSize + 1,
                                          large: defaultFontSize + 2
                                      })

    property string backgroundColor: Kirigami.Theme.backgroundColor
    property string textColor: Kirigami.Theme.textColor
    property string highlightColor: Kirigami.Theme.highlightColor
    property string highlightedTextColor: Kirigami.Theme.highlightedTextColor
    property string buttonBackgroundColor: Kirigami.Theme.buttonBackgroundColor
    property string viewBackgroundColor: Kirigami.Theme.viewBackgroundColor
    property string altColor: Kirigami.Theme.complementaryBackgroundColor
    property string pixColor : pix.pixColor()

    property int iconSize : iconSizes.medium
    property var iconSizes : ({
                                  small :  16,
                                  medium : 22,
                                  large:  48,
                              })
    property int rowHeight : 32

    //    pageStack.defaultColumnWidth: 400
    //    pageStack.initialPage: [mainPage]
    //    pageStack.interactive: isMobile
    //    pageStack.separatorVisible: pageStack.wideMode

    overlay.modal: Rectangle {
        color: isMobile ? altColor : "transparent"
        opacity: 0.5
        height: root.height
    }

    overlay.modeless: Rectangle {
        color: "transparent"
    }

    globalDrawer: GlobalDrawer
    {
        id: globalDrawer
    }

    header: PixsBar
    {
        id: toolBar
        visible: true

        currentIndex: currentView

        onViewerViewClicked: currentView = views.viewer
        onGalleryViewClicked: currentView = views.gallery
        onFoldersViewClicked: currentView = views.folders
        onAlbumsViewClicked: currentView = views.albums
        onTagsViewClicked: currentView = views.tags
        onSearchViewClicked: currentView =  views.search
        onMenuClicked: globalDrawer.open()
    }

    footer: PixFooter
    {
        id: pixFooter
    }
    Page
    {
        id: mainPage
        anchors.fill: parent
        clip: true

        ColumnLayout
        {
            anchors.fill : parent

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
                Layout.bottomMargin: contentMargins*2
                visible: selectionList.count > 0 && currentView !== views.viewer
            }
        }


    }

    PicMenu
    {
        id: picMenu
        onFavClicked: VIEWER.fav(url)
        onRemoveClicked: PIX.removePic(url)
        onShareClicked: isMobile ? android.shareDialog(url) : shareDialog.show(url)
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

    Component.onCompleted: if(isMobile) android.statusbarColor(backgroundColor, textColor)
}
