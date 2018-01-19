import QtQuick 2.9
import QtQuick.Controls 2.2
//import org.kde.kirigami 2.0 as Kirigami

import "widgets"

ApplicationWindow
{
    id: root
    visible: true
    width: 400
    height: 500
    title: qsTr("Pixs")

    property int currentView : 0


    header: PixsBar
    {
        id: toolBar
        visible: true
        size: 24

        currentIndex: currentView

        onViewerViewClicked: currentView = 0
        onGalleryViewClicked: currentView = 1
        onFoldersViewClicked: currentView = 2
        onAlbumsViewClicked: currentView = 3
        onTagsViewClicked: currentView = 4
        onSettingsViewClicked: {}
    }

    Rectangle
    {
        anchors.fill: parent
        color: pix.altColor()
        z: -999
    }

    StackView
    {
        id: stackView
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
