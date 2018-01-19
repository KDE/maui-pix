import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils/Icons.js" as MdiFont
import "../utils"


ToolBar
{
    property string accentColor : pix.pixColor()
    property string textColor : pix.foregroundColor()
    property string backgroundColor : pix.backgroundColor()
    property int size

    property int currentIndex : 0

    signal viewerViewClicked()
    signal galleryViewClicked()
    signal albumsViewClicked()
    signal tagsViewClicked()
    signal foldersViewClicked()
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
            Layout.alignment: Qt.AlignLeft

            ToolButton
            {
                id: viewerView

                Icon
                {
                    id: viewerIcon
                    text: MdiFont.Icon.image
                    color: currentIndex === 0? accentColor : textColor
                    iconSize: size

                }

                onClicked: viewerViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Settings")
            }
        }

        Row
        {
            Layout.alignment: Qt.AlignCenter

            ToolButton
            {
                id: galleryBtn
                Icon
                {
                    text: MdiFont.Icon.imageFilterFrames
                    color: currentIndex === 1? accentColor : textColor
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
                id: foldersView

                Icon
                {
                    id: foldersIcon
                    text: MdiFont.Icon.folderMultipleImage
                    color: currentIndex === 2? accentColor : textColor
                    iconSize: size

                }

                onClicked: foldersViewClicked()
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Tags")
            }

            ToolButton
            {
                id: albumsView
                Icon
                {
                    id: albumsIcon
                    text: MdiFont.Icon.imageMultiple
                    color: currentIndex === 3? accentColor : textColor
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
                    id: tagsIcon
                    text: MdiFont.Icon.tag
                    color: currentIndex === 4? accentColor : textColor
                    iconSize: size

                }

                onClicked: tagsViewClicked()
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Tags")
            }
        }

        Row
        {
            Layout.alignment: Qt.AlignRight

            ToolButton
            {
                id: settingsView

                Icon
                {
                    id: settingsIcon
                    text: MdiFont.Icon.dotsVertical
                    color: currentIndex === 5? accentColor : textColor
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

