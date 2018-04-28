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
    height: Screen.height * (isMobile ? 1 : 0.4)
    visibility: fullScreen ? ApplicationWindow.FullScreen : ApplicationWindow.Windowed

    /* FOR MATERIAL*/
    Material.theme: Material.Light
    Material.accent: pixColor
    Material.background: viewBackgroundColor
    Material.primary: backgroundColor
    Material.foreground: textColor

    /*READONLY PROPS*/

    readonly property bool isMobile : Kirigami.Settings.isMobile
    readonly property bool isAndroid : pix.isAndroid();
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
    /******************** UI UNITS ********************/
    /*************************************************/

    property int iconSize : iconSizes.medium


    readonly property real factor : Kirigami.Units.gridUnit * (isMobile ? 0.2 : 0.2)

    readonly property int contentMargins: space.medium
    readonly property int defaultFontSize: Kirigami.Theme.defaultFont.pointSize
    readonly property var fontSizes: ({
                                          tiny: defaultFontSize * 0.7,

                                          small: (isMobile ? defaultFontSize * 0.7 :
                                                             defaultFontSize * 0.8),

                                          medium: (isMobile ? defaultFontSize * 0.8 :
                                                              defaultFontSize * 0.9),

                                          default: (isMobile ? defaultFontSize * 0.9 :
                                                               defaultFontSize),

                                          big: (isMobile ? defaultFontSize :
                                                           defaultFontSize * 1.1),

                                          large: (isMobile ? defaultFontSize * 1.1 :
                                                             defaultFontSize * 1.2)
                                      })

    readonly property var space : ({
                                       tiny: Kirigami.Units.smallSpacing,
                                       small: Kirigami.Units.smallSpacing*2,
                                       medium: Kirigami.Units.largeSpacing,
                                       big: Kirigami.Units.largeSpacing*2,
                                       large: Kirigami.Units.largeSpacing*3,
                                       huge: Kirigami.Units.largeSpacing*4,
                                       enormus: Kirigami.Units.largeSpacing*5
                                   })

    readonly property var iconSizes : ({
                                           tiny : Kirigami.Units.iconSizes.small*0.5,

                                           small :  (isMobile ? Kirigami.Units.iconSizes.small*0.5:
                                                                Kirigami.Units.iconSizes.small),

                                           medium : (isMobile ? Kirigami.Units.iconSizes.small :
                                                                Kirigami.Units.iconSizes.smallMedium),

                                           big:  (isMobile ? Kirigami.Units.iconSizes.smallMedium :
                                                             Kirigami.Units.iconSizes.medium),

                                           large: (isMobile ? Kirigami.Units.iconSizes.medium :
                                                              Kirigami.Units.iconSizes.large),

                                           huge: (isMobile ? Kirigami.Units.iconSizes.large :
                                                             Kirigami.Units.iconSizes.huge),

                                           enormous: (isMobile ? Kirigami.Units.iconSizes.huge :
                                                                 Kirigami.Units.iconSizes.enormous)

                                       })

    readonly property int rowHeight : (defaultFontSize*2) + space.big

    /***************************************************/
    /**************************************************/
    /*************************************************/

    property bool wideMode: root.width > Kirigami.Units.gridUnit * 40


    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/

    property string backgroundColor: Kirigami.Theme.backgroundColor
    property string textColor: Kirigami.Theme.textColor
    property string highlightColor: Kirigami.Theme.highlightColor
    property string highlightedTextColor: Kirigami.Theme.highlightedTextColor
    property string buttonBackgroundColor: Kirigami.Theme.buttonBackgroundColor
    property string viewBackgroundColor: Kirigami.Theme.viewBackgroundColor
    property string altColor: Kirigami.Theme.complementaryBackgroundColor
    property string pixColor : pix.pixColor()

    /***************************************************/
    /**************************************************/
    /*************************************************/

    overlay.modal: Rectangle {
        color: isAndroid ? altColor : "transparent"
        opacity: 0.2
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
        visible: !fullScreen

        currentIndex: currentView

        onViewerViewClicked: currentView = views.viewer
        onGalleryViewClicked: currentView = views.gallery
        onFoldersViewClicked: currentView = views.folders
        onAlbumsViewClicked: currentView = views.albums
        onTagsViewClicked: currentView = views.tags
        onSearchViewClicked: currentView =  views.search
        onMenuClicked: globalDrawer.visible ? globalDrawer.close() : globalDrawer.open()
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
                Layout.bottomMargin: contentMargins
                Layout.topMargin: space.small
                visible: selectionList.count > 0 && currentView !== views.viewer
            }
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
