import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0


ItemDelegate
{

    property int itemWidth : parent.width
    property int itemHeight : parent.height

    height: itemHeight
    width: itemWidth

    background: Rectangle
    {
        color: "transparent"
    }

    Image
    {
        id: pic
        anchors.centerIn: parent
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        width: parent.width
        height: parent.height
        source: "file://"+url
        fillMode: Image.PreserveAspectFit
        cache: true
        asynchronous: true

        MouseArea
        {
            anchors.fill: parent
            acceptedButtons:  Qt.LeftButton | Qt.RightButton

            onEntered: galleryRoll.visible = !galleryRoll.visible
            onPressAndHold: picMenu.show(currentPic.url)

            onWheel: wheel.angleDelta.y > 0 ? zoomIn() : zoomOut()

            onClicked: if(!isMobile && mouse.button === Qt.RightButton)
                           picMenu.show(currentPic.url)
        }

        //        BrightnessContrast
        //        {
        //            anchors.fill: pic
        //            source: pic
        //            brightness: picBrightness
        //            contrast: picContrast
        //        }

        //        HueSaturation
        //        {
        //            anchors.fill: pic
        //            source: pic
        //            hue: picHue
        //            saturation: picSaturation
        //            lightness: picLightness
        //        }
    }

    function zoomIn()
    {
        pic.width = pic.width + 50
    }

    function zoomOut()
    {
        pic.width = pic.width - 50
    }

    function fit()
    {
        pic.width = pic.sourceSize.width
    }

    function fill()
    {
        pic.width = parent.width
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
