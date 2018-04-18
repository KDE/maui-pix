import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

ToolButton
{
    id: babeButton

    property alias kirigamiIcon : pixIcon

    property string iconName
    property int size : iconSize
    property color iconColor: textColor
    readonly property string defaultColor :  textColor
    property bool anim : false

    Kirigami.Icon
    {
        id: pixIcon
        anchors.centerIn: parent
        width: size
        height: size
        visible: true
        color: iconColor
        source: iconName
        isMask: true
    }


    onClicked: if(anim) animIcon.running = true

    flat: true
    highlighted: false


    SequentialAnimation
    {
        id: animIcon
        PropertyAnimation
        {
            target: pixIcon
            property: "color"
            easing.type: Easing.InOutQuad
            from: pix.pixColor()
            to: iconColor
            duration: 500
        }
    }
}


