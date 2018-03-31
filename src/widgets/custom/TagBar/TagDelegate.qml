import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

ItemDelegate
{
    clip: true

    property int tagWidth: 100
    property int tagHeight: 24

    height: tagHeight
    width: tagWidth

    anchors.verticalCenter: parent.verticalCenter

    background: Image
    {
        source: "qrc:/img/assets/tag.svg"
        sourceSize.width: tagWidth
        width: tagWidth
    }

    RowLayout
    {
        anchors.fill: parent

        Label
        {
            id: tagLabel
            text: tag
            height: parent.height
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: contentMargins*2
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            elide: Qt.ElideRight
            font.pointSize: fontSizes.small
        }

        PixButton
        {
            iconName: "window-close"
            iconSize: 16
            Layout.fillHeight: true

        }
    }
}
