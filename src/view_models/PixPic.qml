import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2

Image
{
    id: img

    signal picClicked(int index)
    property int picSize : 150
    property int picRadius : 2

    width: picSize
    height: picSize
    cache: false
    antialiasing: true
    fillMode: Image.PreserveAspectFit
    source: (url && url.length>0)? "file://"+encodeURIComponent(url) : "qrc:/../assets/face.png"

    Rectangle {
        id: border; color: 'white'; anchors.centerIn: parent; antialiasing: true
        width: img.paintedWidth + 6; height: img.paintedHeight + 6
        z: -999
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            parent.GridView.view.currentIndex = index
            img.picClicked(index)
        }
    }
}
