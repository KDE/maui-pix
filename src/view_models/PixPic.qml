import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ItemDelegate
{  
    id: control

    property int picRadius : 0
    property bool showLabel : true
    property bool showIndicator : false
    property bool showEmblem:  true
    property bool fit : false
    property bool cachePic: false
    property bool dropShadow: false

    property alias source : img.source
    property alias label : _label.text

    property color labelColor : (selected || isCurrentItem || selected) && !hovered ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
    property color hightlightedColor : selected || isCurrentItem || hovered  ? Kirigami.Theme.highlightColor : "transparent"

    property bool selected : false

    signal emblemClicked();

    padding: Maui.Style.space.medium

    Maui.Badge
    {
        id: emblem
        iconName: selected ? "list-remove" : "list-add"
        visible: control.hovered || control.showEmblem || control.selected
        z: 999
        anchors.top: parent.top
        anchors.left: parent.left
        onClicked:
        {
            control.selected = !control.selected
            control.emblemClicked(index)
        }
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.tiny
        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            Image
            {
                id: img
                anchors.fill: parent
                sourceSize.height: height
                sourceSize.width: width
                cache: control.cachePic
                antialiasing: true
                asynchronous: true
                smooth: true
                fillMode: control.fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                source: (model.url && model.url.length>0) ? model.url : "qrc:/img/assets/image-x-generic.svg"

                Rectangle
                {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: control.showIndicator
                    color: control.isCurrentItem ? Kirigami.Theme.highlightColor : "transparent"
                    height: Maui.Style.iconSizes.small
                    width: Maui.Style.iconSizes.small
                    radius: Math.min(width, height)
                }

                layer.enabled: true
                layer.effect: OpacityMask
                {
                    maskSource:  Rectangle
                    {
                        width: img.width
                        height: img.height
                        radius: control.picRadius
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

            DropShadow
            {
                anchors.fill: img
                visible: control.dropShadow
                horizontalOffset: 0
                verticalOffset: 0
                radius: 8.0
                samples: 17
                color: "#80000000"
                source: img
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
