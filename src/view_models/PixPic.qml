import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ItemDelegate
{  
    id: control

    property int picSize : Maui.Style.iconSizes.enormous
    property int picRadius : 0
    property bool showLabel : true
    property bool showIndicator : false
    property bool showEmblem:  true
    property bool fit : false
    property bool isHovered :  hovered
    property bool cachePic: false

    property alias source : img.source
    property alias label : _label.text

    property string indicatorColor: ListView.isCurrentItem ? Kirigami.Theme.highlightColor : "transparent"

    property color labelColor : (GridView.isCurrentItem || (keepEmblemOverlay && emblemAdded)) && !hovered && showSelectionBackground? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
    property color hightlightedColor : GridView.isCurrentItem || hovered || (keepEmblemOverlay && emblemAdded) ? Kirigami.Theme.highlightColor : "transparent"

    property bool showSelectionBackground : true

    property bool emblemAdded : false
    property bool keepEmblemOverlay : false

//    signal rightClicked();
    signal emblemClicked();

    hoverEnabled: !Kirigami.Settings.isMobile
    focus: true

    background: Rectangle
    {
        color: "transparent"
    }

//    MouseArea
//    {
//        anchors.fill: parent
//        acceptedButtons:  Qt.RightButton
//        onClicked:
//        {
//            if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
//                rightClicked()
//        }
//    }

    Maui.Badge
    {
        id: emblem
        iconName: "list-add"
        visible: isHovered || showEmblem
        z: 999
        anchors.top: parent.top
        anchors.left: parent.left
        onClicked:
        {
            emblemAdded = !emblemAdded
            emblemClicked(index)
        }
    }

    ColumnLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            Image
            {
                id: img
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                sourceSize.height: height
                sourceSize.width: width
                cache: control.cachePic
                antialiasing: true
                asynchronous: true
                smooth: true
                fillMode: fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                source: (url && url.length>0) ? model.url : "qrc:/img/assets/image-x-generic.svg"

                Rectangle
                {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: showIndicator
                    color: indicatorColor
                    height: Maui.Style.iconSizes.small
                    width: Maui.Style.iconSizes.small
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

                Kirigami.Icon
                {
                    visible:  img.status !== Image.Ready
                    source: "image-x-generic"
                    width: Math.min(parent.height, Maui.Style.iconSizes.huge)
                    height: width
                    anchors.centerIn: parent
                }
            }

            Rectangle
            {
                anchors.fill: parent
                color: hovered ? "#333" : "transparent"
                opacity: hovered ?  0.3 : 0
                radius: picRadius
            }
        }

        Item
        {
            height: showLabel ? (Maui.Style.unit * 24) + Maui.Style.space.small : 0
            Layout.fillWidth: true
            Layout.maximumHeight: height
            Layout.minimumHeight: height
            Layout.preferredHeight: height
            visible: showLabel

            Label
            {
                id: _label
                text: model.title
                width: parent.width
                height: parent.height
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                elide: Qt.ElideRight
                wrapMode: Text.Wrap
                font.pointSize: Maui.Style.fontSizes.default
                color: labelColor

                Rectangle
                {
                    visible: parent.visible && showSelectionBackground
                    anchors.fill: parent
                    z: -1
                    radius: Maui.Style.radiusV
                    color: hightlightedColor
                    opacity: hovered ? 0.25 : 1
                }
            }
        }
    }
}
