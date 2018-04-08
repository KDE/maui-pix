import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

ItemDelegate
{  
    property int picSize : 150
    property int picRadius : 0
    property bool showLabel : true
    property bool showIndicator : false
    property string indicatorColor: ListView.isCurrentItem ? highlightColor : "transparent"
    property color labelColor : GridView.isCurrentItem ? highlightedTextColor : textColor

    signal rightClicked();

    height: picSize
    width: picSize

    background: Rectangle
    {
        color: "transparent"
    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton
        onClicked:
        {
            if(!isMobile && mouse.button === Qt.RightButton)
                rightClicked()
        }
    }

    ColumnLayout
    {
        anchors.fill: parent
        Image
        {
            id: img
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            sourceSize.height: picSize-contentMargins
            sourceSize.width: picSize-contentMargins
            cache: true
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectCrop
            source: (url && url.length>0)?
                        "file://"+encodeURIComponent(url) :
                        "qrc:/../assets/face.png"
            asynchronous: true

            Rectangle
            {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                visible: showIndicator
                color: indicatorColor
                height: 12
                width: 12
                radius: Math.min(width, height)
            }

            layer.enabled: picRadius > 0
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: img.sourceSize.width
                    height: img.sourceSize.height
                    Rectangle
                    {
                        anchors.centerIn: parent
                        width: img.adapt ? img.sourceSize.width : Math.min(img.sourceSize.width, img.sourceSize.height)
                        height: img.adapt ? img.sourceSize.height : width
                        radius: picRadius
                    }
                }
            }

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
            color: labelColor
        }
    }
}
