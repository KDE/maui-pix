import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

ItemDelegate
{
    clip: true

    property int tagWidth: 100
    property int tagHeight: 24

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
                font.pointSize: fontSizes.small
            }
        }

        Item
        {
            Layout.fillHeight: true
            width: 16
            Layout.maximumWidth: 16
            Layout.margins: 5
            PixButton
            {
                anchors.centerIn: parent

                iconName: "window-close"
                iconSize: 16
                onClicked: removeTag(index)

            }
        }

    }
}
