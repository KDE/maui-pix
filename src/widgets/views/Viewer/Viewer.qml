import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "../../"

Item
{
    property bool autoSaveTransformation : false
    property real picContrast : 0
    property real picBrightness : 0
    property real picSaturation : 0
    property real picHue : 0
    property real picLightness : 0

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
