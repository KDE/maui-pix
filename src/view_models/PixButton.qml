import QtQuick 2.9
import QtQuick.Controls 2.2
import "../utils"
import org.kde.kirigami 2.2 as Kirigami

ToolButton
{
    id: babeButton

    property string iconName
    property int iconSize : 22
    property color iconColor: textColor
    readonly property string defaultColor :  textColor
    property bool anim : false

    icon.name: iconName
    icon.width: iconSize
    icon.height: iconSize
    icon.color: iconColor

    onClicked: if(anim) animIcon.running = true

    flat: true
    highlighted: false


    SequentialAnimation
    {
        id: animIcon
        PropertyAnimation
        {
            target: babeButton
            property: "color"
            easing.type: Easing.InOutQuad
            from: pix.pixColor()
            to: iconColor
            duration: 500
        }
    }
}


