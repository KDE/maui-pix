import QtQuick 2.0
import QtQuick.Controls 2.2

Image {

    height: parent.height
    width: parent.width
    source: "file://"+currentPic.url
    fillMode: Image.PreserveAspectFit

}
