import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

ItemDelegate
{
    clip: true

    property int tagWidth: iconSizes.medium*4
    property int tagHeight: iconSizes.medium

    signal removeTag(int index)

    height: tagHeight
    width: tagWidth

    anchors.verticalCenter: parent.verticalCenter

    background: Image
    {
        source: "qrc:/img/assets/tag.svg"
        sourceSize.width: tagWidth
        sourceSize.height: tagHeight
        width: tagWidth
        height: tagHeight
    }

    RowLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: tagWidth *0.2
            Label
            {
                id: tagLabel
                text: tag
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                elide: Qt.ElideRight
                font.pointSize: fontSizes.medium
            }
        }

        Item
        {
            Layout.fillHeight: true
            width: iconSizes.small
            Layout.maximumWidth: iconSizes.small
            Layout.margins: space.small
            PixButton
            {
                anchors.centerIn: parent

                iconName: "window-close"
                size: iconSizes.small
                onClicked: removeTag(index)

            }
        }

    }
}
