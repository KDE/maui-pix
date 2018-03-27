import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

PixPage
{

    property alias viewer : viewer

    property var currentPic : ({})


    headerbarTitle: currentPic.title || ""
    headerbarExit: false
    headerBarRight: [

        PixButton
        {
            iconName: "edit-rename"
        },

        PixButton
        {
            iconName: "documentinfo"
        }

    ]

    headerBarLeft: [

        PixButton
        {
            iconName: "document-save-as"
        },

        PixButton
        {
            iconName: "draw-text"
        }
    ]

    footer: ToolBar
    {
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

                    onClicked: pix.openWith(currentPic.url)
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

                    iconName: "love"

                    hoverEnabled: !isMobile
                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Fav")
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

    PixHolder
    {
        message: "<h2>No Pic!</h2><p>Select or open an image from yuor gallery</p>"
        emoji: "qrc:/img/assets/face-hug.png"
        visible: Object.keys(currentPic).length === 0
    }

    content: Viewer
    {
    id: viewer
    }

}
