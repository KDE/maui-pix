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

    fillMode: Image.PreserveAspectFit
    source: (url && url.length>0)? "file://"+encodeURIComponent(url) : "qrc:/../assets/face.png"

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
