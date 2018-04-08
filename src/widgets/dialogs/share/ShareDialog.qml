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

    function show(url)
    {
        picUrl = url
        open()
    }

    function populate()
    {
        shareGrid.model.clear()
        var services = pix.openWith(picUrl)
        var devices = pix.getDevices()

        shareGrid.model.append({serviceIcon: "internet-mail", serviceLabel: "eMail", email: true})

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
        else if(obj.email)
            pix.attachToEmail(picUrl)
        else
            pix.runApplication(obj.actionArgument, picUrl)

        shareDialog.close()
    }
}

