import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../../../view_models"

PixPopup
{
    property string picUrl : ""

    padding: contentMargins
    maxWidth: (shareGrid.cellWidth*3)+(contentMargins*3)
    height: 230
    parent: parent

    ColumnLayout
    {
        anchors.fill: parent
        height: parent.height
        width:parent.width

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
            width: parent.width
            onServiceClicked: triggerService(index)
        }
    }


    onOpened: populate()

    function populate()
    {
        shareGrid.model.clear()
        var services = pix.openWith(pixViewer.currentPic.url)
        var devices = pix.getDevices()

        if(devices.length > 0)
            for(var i in devices)
            {
                devices[i].serviceIcon = "smartphone"
                shareGrid.model.append(devices[i])

            }

        if(services.length > 0)
            for(i in services)
                shareGrid.model.append(services[i])

    }

    function triggerService(index)
    {
        var obj = shareGrid.model.get(index)

        if(obj.serviceKey)
            pix.sendToDevice(obj.serviceLabel, obj.serviceKey, picUrl)
        else
            pix.runApplication(obj.actionArgument, picUrl)

        shareDialog.close()
    }
}

