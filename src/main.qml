import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami

import "widgets"
import "widgets/views/Albums"
import "widgets/views/Folders"
import "widgets/views/Gallery"
import "widgets/views/Settings"
import "widgets/views/Tags"
import "widgets/views/Viewer"

import "view_models"

import "widgets/views/Pix.js" as PIX

Kirigami.ApplicationWindow
{
    id: root
    visible: true
    width: 400
    height: 500
    title: qsTr("Pixs")

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

    property int iconSize : Kirigami.Units.iconSizes.medium

    overlay.modal: Rectangle {
        color: isMobile ? darkColor : "transparent"
        opacity: 0.5
        height: root.height
    }

    overlay.modeless: Rectangle {
        color: "transparent"
    }

    header: PixsBar
    {
        id: toolBar
        visible: true

        currentIndex: currentView

        onViewerViewClicked: currentView = 0
        onGalleryViewClicked: currentView = 1
        onFoldersViewClicked: currentView = 2
        onAlbumsViewClicked: currentView = 3
        onTagsViewClicked: currentView = 4
        onSearchViewClicked: {}
    }

    footer: PixFooter
    {
    }

    SwipeView
    {
        id: swipeView
        anchors.fill: parent

        currentIndex: currentView

        onCurrentIndexChanged:
        {
            currentView = currentIndex
        }

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

        }

        SettingsView
        {

        }

    }

    Connections
    {
        target: pix

        onRefreshViews: PIX.refreshViews()
    }

}
