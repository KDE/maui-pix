import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"

ItemDelegate
{
    property int folderSize : 32

    height: folderSize*2
    width: folderSize*2

    PixButton
    {
        anchors.centerIn: parent
        iconSize: folderSize
        iconName: "folder"
        text: folder
        display: AbstractButton.TextUnderIcon
        flat: true
        height: parent.height
        width: parent.width


    }
}
