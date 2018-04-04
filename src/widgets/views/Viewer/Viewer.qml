import QtQuick 2.9
import QtQuick.Controls 2.2

Item
{
    property bool autoSaveTransformation : false
    clip: true

    Image
    {
        id: pic
        anchors.centerIn: parent
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        height: parent.height
        source: "file://"+currentPic.url
        fillMode: Image.PreserveAspectFit
        cache: true
        asynchronous: true
        MouseArea
        {
            anchors.fill: parent
            onEntered: galleryRoll.visible = !galleryRoll.visible

            onWheel: wheel.angleDelta.y > 0 ? zoomIn() : zoomOut()
        }
    }

    function zoomIn()
    {
         pic.height = pic.height + 50
    }

    function zoomOut()
    {
        pic.height = pic.height - 50
    }

    function fit()
    {
        pic.height = pic.sourceSize.height
    }

    function fill()
    {
        pic.height = parent.height
    }

    function rotateLeft()
    {
        pic.rotation = pic.rotation - 90
    }

    function rotateRight()
    {
        pic.rotation = pic.rotation + 90

    }
}
