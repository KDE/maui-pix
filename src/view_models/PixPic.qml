import QtQuick 2.9
import QtQuick.Controls 2.2

ItemDelegate
{
    height: picSize
    width: picSize
    property int picSize : 150
    property int picRadius : 2

    Image
    {
        id: img
        anchors.centerIn: parent
        height: picSize-contentMargins
        width: picSize-contentMargins
        sourceSize.height: picSize-contentMargins
        sourceSize.width: picSize-contentMargins
        cache: true
        antialiasing: true
        fillMode: Image.PreserveAspectCrop
        source: (url && url.length>0)? "file://"+encodeURIComponent(url) : "qrc:/../assets/face.png"
        asynchronous: true

    }

}
