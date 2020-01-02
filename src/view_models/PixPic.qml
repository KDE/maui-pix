import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ItemDelegate
{  
    id: control

    property bool showIndicator : false
    property bool showEmblem:  true
    property bool fit : false
    property bool dropShadow: false
    property bool selected : false
    property alias labelsVisible: _template.labelsVisible

    signal emblemClicked();

    padding: Maui.Style.space.medium    

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered
    ToolTip.text: model.url

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

    Rectangle
    {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: control.showIndicator && control.isCurrentItem
        color: Kirigami.Theme.highlightColor
        height: Maui.Style.iconSizes.small
        width: Maui.Style.iconSizes.small
        radius: Math.min(width, height)
        z: 999
    }

    //    Kirigami.Icon
    //    {
    //        visible:  img.status !== Image.Ready
    //        source: "image-x-generic"
    //        width: Math.min(parent.height, Maui.Style.iconSizes.huge)
    //        height: width
    //        anchors.centerIn: parent
    //    }

    Maui.GridItemTemplate
    {
        id: _template
        isCurrentItem: (control.isCurrentItem || control.selected) && !labelsVisible
        anchors.fill: parent
        iconSizeHint: height - Maui.Style.space.tiny
        label1.text: model.title
        imageSource: (model.url && model.url.length>0) ? model.url : "qrc:/img/assets/image-x-generic.svg"
        fillMode: control.fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop
    }

    DropShadow
    {
        anchors.fill: _template
        visible: control.dropShadow
        horizontalOffset: 0
        verticalOffset: 0
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: _template
    }
}
