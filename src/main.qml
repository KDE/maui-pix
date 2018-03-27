import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami

import "widgets"
import "view_models"

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
                                          standar: defaultFontSize,
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


    StackView
    {
        id: stackView
        clip: true
        anchors.fill: parent

        initialItem: SwipeView
        {
            id: swipeView
            width: parent.width
            height: parent.height

            currentIndex: currentView

            onCurrentIndexChanged:
            {
                currentView = currentIndex
            }

            PixsViewer
            {

            }

            GalleryView
            {

            }

            AlbumsView
            {

            }

            TagsView
            {

            }

            SettingsView
            {

            }

        }

        Component
        {
            id: viewer
            PixsViewer
            {

            }
        }


    }

}
