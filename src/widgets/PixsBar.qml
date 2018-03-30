import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils/Icons.js" as MdiFont
import "../utils"
import "../view_models"


ToolBar
{
    position: ToolBar.Header

    property string accentColor : pix.pixColor()
    property string textColor : textColor

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

        Item
        {
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true
            Layout.fillHeight: true

            PixButton
            {
                anchors.centerIn: parent

                iconName: "application-menu"
                onClicked: menuClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Menu")
            }
        }

        Item { Layout.fillWidth: true }

        Item
        {
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true
            Layout.fillHeight: true

            PixButton
            {
                id: viewerView
                anchors.centerIn: parent
                iconColor: currentIndex === views.viewer? accentColor : textColor

                iconName: "view-preview"
                onClicked: viewerViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Viewer")
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PixButton
            {
                id: galleryBtn
                anchors.centerIn: parent

                iconColor: currentIndex === views.gallery? accentColor : textColor

                iconName: "image-frames"
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

            PixButton
            {
                id: foldersView
                anchors.centerIn: parent

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

            PixButton
            {
                id: albumsView
                anchors.centerIn: parent

                iconColor: currentIndex === views.albums? accentColor : textColor

                iconName: "image-multiple"
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

            PixButton
            {
                id: tagsView
                anchors.centerIn: parent

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
        Item { Layout.fillWidth: true }

        Item
        {
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: true


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

