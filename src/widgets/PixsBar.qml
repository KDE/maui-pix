import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils"
import "../view_models"


ToolBar
{
    position: ToolBar.Header

    property string accentColor : pix.pixColor()

    property int currentIndex : 0

    signal viewerViewClicked()
    signal galleryViewClicked()
    signal albumsViewClicked()
    signal tagsViewClicked()
    signal foldersViewClicked()
    signal searchViewClicked()

    signal menuClicked()

    id: pixBar

    RowLayout
    {
        anchors.fill: parent
        spacing: space.medium
        Item
        {
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: iconSize*2

            PixButton
            {
                anchors.centerIn: parent

                iconName: "application-menu"
                onClicked: menuClicked()

                iconColor: globalDrawer.visible ? accentColor : textColor

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Menu")
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }


        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: galleryBtn.implicitWidth * 1.3

            PixButton
            {
                id: galleryBtn
                anchors.centerIn: parent
                text: qsTr("Gallery")
                iconColor: currentIndex === views.gallery? accentColor : textColor

                iconName: "image-multiple"
                onClicked: galleryViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Gallery")
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: foldersView.implicitWidth * 1.3

            PixButton
            {
                id: foldersView
                anchors.centerIn: parent
                text: qsTr("Folders")
                iconColor: currentIndex === views.folders? accentColor : textColor

                iconName: "image-folder-view"
                onClicked: foldersViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Folders")
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: albumsView.implicitWidth * 1.3

            PixButton
            {
                id: albumsView
                anchors.centerIn: parent
                text: qsTr("Albums")
                iconColor: currentIndex === views.albums? accentColor : textColor

                iconName: "image-frames"
                onClicked: albumsViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Albums")
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: tagsView.implicitWidth * 1.3

            PixButton
            {
                id: tagsView
                anchors.centerIn: parent
                text: qsTr("Tags")
                iconColor: currentIndex === views.tags? accentColor : textColor

                iconName: "tag"
                onClicked: tagsViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Tags")
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        Item
        {
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: iconSize*2

            PixButton
            {
                id: searchView
                anchors.centerIn: parent

                iconColor: currentIndex === views.search? accentColor : textColor

                iconName: "edit-find"
                onClicked: searchViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Search")
            }
        }
    }
}

