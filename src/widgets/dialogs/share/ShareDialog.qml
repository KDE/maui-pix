import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../../../view_models"

PixPopup
{

    property string picUrl : ""

    padding: contentMargins
    width: 260
    height: 230
    parent: parent

    ColumnLayout
    {
        anchors.fill: parent

        Label
        {
            text: qsTr("Open with...")
            width: parent.width
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            elide: Qt.ElideRight
            font.pointSize: fontSizes.big
            padding: contentMargins
            font.bold: true

        }

        ShareGrid
        {
            id: shareGrid
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }


    onOpened: populate()

    function populate()
    {
        var services = pix.openWith(pixViewer.currentPic.url)

        if(services.length>0)
            for(var i in services)
              shareGrid.model.append(services[i])

    }
}
