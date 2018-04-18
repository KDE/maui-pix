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

    background: Rectangle
    {
        color: "transparent"
    }

    ColumnLayout
    {
        height: parent.height * 0.8
        width: parent.width * 0.9
        spacing: space.medium

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Kirigami.Icon
            {
                anchors.centerIn: parent
                source: "folder"
                isMask: false
                height: folderSize
                width: folderSize
            }
        }



        Label
        {
            text: folder
            width: parent.width
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            elide: Qt.ElideRight
            font.pointSize: fontSizes.default
            color: labelColor

            Rectangle
            {
                visible: parent.visible
                anchors.fill: parent
                z: -1
                radius: 3
                color: hightlightedColor
                opacity: hovered ? 0.25 : 1
            }
        }
    }


}
