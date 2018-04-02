import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ItemDelegate
{  
    property int picSize : 150
    property int picRadius : 2
    property bool showLabel : true
    height: picSize
    width: picSize

    background: Rectangle
    {
        color: "transparent"
    }

    ColumnLayout
    {
        anchors.fill: parent
        Image
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            sourceSize.height: picSize-contentMargins
            sourceSize.width: picSize-contentMargins
            cache: true
            antialiasing: true
            fillMode: Image.PreserveAspectCrop
            source: (url && url.length>0)?
                        "file://"+encodeURIComponent(url) :
                        "qrc:/../assets/face.png"
            asynchronous: true

        }
        Label
        {
            text: title
            visible: showLabel
            width: parent.width
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            elide: Qt.ElideRight
            font.pointSize: fontSizes.default
        }
    }
}
