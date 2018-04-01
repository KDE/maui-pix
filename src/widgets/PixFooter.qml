import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../view_models"
import "../widgets/views/Viewer/Viewer.js" as VIEWER
ToolBar
{
    id: footerToolbar
    visible: !pixViewer.holder.visible && currentView === views.viewer
    position: ToolBar.Footer

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

                iconName: "document-share"

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Share")

                onClicked:
                {
                    shareDialog.picUrl = pixViewer.currentPic.url
                    shareDialog.open()
                }
            }
        }

        Item { Layout.fillWidth: true }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: iconSize*2

            PixButton
            {
                anchors.centerIn: parent

                iconName: "go-previous"

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Previous")

                onClicked: VIEWER.previous()
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: iconSize*2

            PixButton
            {
                id: favIcon
                anchors.centerIn: parent

                iconName: "love"
                iconColor: pixViewer.currentPicFav? pix.pixColor() : textColor
                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Fav")

                onClicked: pixViewer.currentPicFav = VIEWER.fav(pixViewer.currentPic.url)

            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: iconSize*2

            PixButton
            {
                anchors.centerIn: parent

                iconName: "go-next"

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Next")

                onClicked: VIEWER.next()
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
                anchors.centerIn: parent

                iconName: "view-fullscreen"

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Fullscreen")
            }
        }

    }
}
