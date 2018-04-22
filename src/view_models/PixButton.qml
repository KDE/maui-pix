import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

import QtQuick.Controls.impl 2.3

ToolButton
{
    id: babeButton

    property bool isMask :  true
    property string iconName
    property int size : iconSizes.medium
    property color iconColor: textColor
    readonly property string defaultColor :  textColor
    property bool anim : false

    spacing: space.small
    icon.name:  iconName
    icon.width:  size
    icon.height:  size
    icon.color: !isMask  ?  "transparent" : (down ? highlightColor : (iconColor || defaultColor))
    display: wideMode ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly

    onClicked: if(anim) animIcon.running = true

    flat: true
    highlighted: false

    contentItem: IconLabel
    {
        spacing: babeButton.spacing
        mirrored: babeButton.mirrored
        display: babeButton.display

        icon: babeButton.icon
        text: babeButton.text
        font: babeButton.font
        color: iconColor
    }

    SequentialAnimation
    {
        id: animIcon
        PropertyAnimation
        {
            target: babeButton
            property: "icon.color"
            easing.type: Easing.InOutQuad
            from: highlightColor
            to: iconColor
            duration: 500
        }
    }
}


