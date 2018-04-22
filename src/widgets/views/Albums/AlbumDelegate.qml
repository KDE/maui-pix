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
        anchors.fill: parent
        spacing: space.small

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: albumSize
            Layout.alignment: Qt.AlignCenter

            Image
            {
                anchors.centerIn: parent
                source: "qrc:/img/assets/album.svg"

                height: albumSize
                sourceSize.height: albumSize
                sourceSize.width: albumSize
                cache: true
                antialiasing: true
                fillMode: Image.PreserveAspectFit

            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: parent.height * 0.3
            Layout.alignment: Qt.AlignTop

            Label
            {
                text: album
                width: parent.width * 0.8
                height: parent.height
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
                    radius: albumSize*0.05
                    color: hightlightedColor
                    opacity: hovered ? 0.25 : 1
                }
            }
        }
    }


}
