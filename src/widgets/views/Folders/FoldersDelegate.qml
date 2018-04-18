import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

ItemDelegate
{
    property int folderSize : iconSizes.big

    property color hightlightedColor : GridView.isCurrentItem || hovered  ? highlightColor : "transparent"
    property color labelColor : GridView.isCurrentItem  && !hovered ? highlightedTextColor : textColor

    hoverEnabled: !isMobile
    focus: true

    background: Rectangle
    {
        color: "transparent"
    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: space.small

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: folderSize
            Layout.alignment: Qt.AlignCenter

            Kirigami.Icon
            {
                anchors.centerIn: parent
                source: "folder"
                isMask: false
                height: folderSize
                width: folderSize
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            Label
            {
                text: folder
                width: parent.width *0.8
                anchors.centerIn: parent
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                elide: Qt.ElideRight
                font.pointSize: fontSizes.default
                color: labelColor

                Rectangle
                {
                    visible: parent.visible
                    anchors.fill: parent
                    z: -1
                    radius: folderSize*0.05
                    color: hightlightedColor
                    opacity: hovered ? 0.25 : 1
                }
            }
        }
    }
}
