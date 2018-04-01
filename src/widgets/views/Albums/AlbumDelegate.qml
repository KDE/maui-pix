import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import org.kde.kirigami 2.2 as Kirigami

ItemDelegate
{
    property int albumSize : 32

    height: albumSize*2
    width: albumSize*3

    background: Rectangle
    {
        color: "transparent"
    }

    ColumnLayout
    {
        anchors.fill: parent

        Image
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            source: "qrc:/img/assets/album_bg_normal.png"

            height: albumSize
            sourceSize.height: albumSize
            sourceSize.width: albumSize
            cache: true
            antialiasing: true
            fillMode: Image.PreserveAspectFit

        }

        Label
        {
            text: album
            width: parent.width
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            elide: Qt.ElideRight
            font.pointSize: fontSizes.default
        }
    }


}
