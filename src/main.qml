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

    property int currentView : 0
    property int columnWidth: 32

    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [sidebar, stackView]
    pageStack.separatorVisible: pageStack.wideMode

    property string backgroundColor: Kirigami.Theme.backgroundColor
    property string textColor: Kirigami.Theme.textColor
    property string highlightColor: Kirigami.Theme.highlightColor
    property string highlightedTextColor: Kirigami.Theme.highlightedTextColor
    property string buttonBackgroundColor: Kirigami.Theme.buttonBackgroundColor
    property string viewBackgroundColor: Kirigami.Theme.viewBackgroundColor

    //    header: PixsBar
    //    {
    //        id: toolBar
    //        visible: true
    //        size: 24

    //        currentIndex: currentView

    //        onViewerViewClicked: currentView = 0
    //        onGalleryViewClicked: currentView = 1
    //        onFoldersViewClicked: currentView = 2
    //        onAlbumsViewClicked: currentView = 3
    //        onTagsViewClicked: currentView = 4
    //        onSettingsViewClicked: {}
    //    }



    SideBar
    {
        id: sidebar
    }


    StackView
    {
        id: stackView
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
