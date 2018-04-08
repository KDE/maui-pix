import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

ItemDelegate
{
    property int iconSize : 48
    property string labelColor: GridView.isCurrentItem ? highlightedTextColor : textColor

    height: 64
    width: 100

    background: Rectangle
    {
        color: "transparent"
    }

    ColumnLayout
    {
        anchors.fill: parent

        Kirigami.Icon
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            source: serviceIcon
            isMask: false

            height: iconSize
            width: iconSize

        }

        Label
        {
            text: serviceLabel
            width: parent.width
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            elide: Qt.ElideRight
            font.pointSize: fontSizes.default
            color: labelColor
        }
    }
}
