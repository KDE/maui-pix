import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils/Icons.js" as MdiFont
import "../utils"


ToolBar
{
    property string accentColor : "#75ff75"
    property string textColor : "#ffffff"
    property string backgroundColor : "#31363b"    
    property int size

    property int currentIndex : 0

    signal galleryViewClicked()
    signal albumsViewClicked()
    signal tagsViewClicked()
    signal settingsViewClicked()


    id: pixBar

    Rectangle
    {
        anchors.fill: parent
        color: backgroundColor
    }

    RowLayout
    {
        anchors.fill: parent

        Row
        {
            anchors.centerIn: parent

            ToolButton
            {
                id: galleryBtn
                Icon
                {
                    text: MdiFont.Icon.image
                    color: currentIndex === 0? accentColor : textColor
                    iconSize: size
                }

                onClicked: galleryViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Gallery")
            }

            ToolButton
            {
                id: albumsView
                Icon
                {
                    id: albumsIcon
                    text: MdiFont.Icon.burstMode
                    color: currentIndex === 1? accentColor : textColor
                    iconSize: size

                }

                onClicked: albumsViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Albums")
            }

            ToolButton
            {
                id: tagsView

                Icon
                {
                    id: artistsIcon
                    text: MdiFont.Icon.tagFaces
                    color: currentIndex === 2? accentColor : textColor
                    iconSize: size

                }

                onClicked: tagsViewClicked()
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Tags")
            }


            ToolButton
            {
                id: settingsView

                Icon
                {
                    id: settingsIcon
                    text: MdiFont.Icon.settings
                    color: currentIndex === 3? accentColor : textColor
                    iconSize: size

                }

                onClicked: settingsViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Settings")
            }
        }
    }
}

