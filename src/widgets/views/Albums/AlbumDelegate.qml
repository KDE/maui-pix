import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import org.kde.kirigami 2.2 as Kirigami

ItemDelegate
{
    property int albumSize :  iconSizes.large
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
            Layout.alignment: Qt.AlignCenter

            Image
            {
                anchors.centerIn: parent
                source: "qrc:/img/assets/album_bg_normal.png"

                height: albumSize
                sourceSize.height: albumSize
                sourceSize.width: albumSize
                cache: true
                antialiasing: true
                fillMode: Image.PreserveAspectFit

            }
        }

        Label
        {
            text: album
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
