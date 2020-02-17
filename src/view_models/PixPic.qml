import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ItemDelegate
{
    id: control

    property bool showEmblem:  true
    property bool keepEmblem:  false
    property bool fit : false
    property bool dropShadow: false
    property bool selected : false
    property alias labelsVisible: _template.labelsVisible

    signal emblemClicked();

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered
    ToolTip.text: model.url

   radius:  labelsVisible ? Maui.Style.radiusV : 4

    Maui.GridItemTemplate
    {
        id: _template
        maskRadius: control.radius
        isCurrentItem: (control.isCurrentItem) && !labelsVisible
        anchors.fill: parent
        anchors.margins: 4
        iconSizeHint: labelsVisible ? height * 0.7 : height
        imageHeight: Math.max(height, 200)
        imageWidth: Math.max(width, 200)
        label1.text: model.title
        imageSource: (model.url && model.url.length>0) ? model.url : "qrc:/img/assets/image-x-generic.svg"
        fillMode: control.fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop

        emblem.iconName: selected ? "checkbox" : " "
        emblem.visible: (control.selected || control.keepEmblem) &&  control.showEmblem
        emblem.border.color: emblem.Kirigami.Theme.textColor
        emblem.color: control.selected ? emblem.Kirigami.Theme.highlightColor : emblem.Kirigami.Theme.backgroundColor

        Connections
        {
            target: _template.emblem
            onClicked:
            {
                control.selected = !control.selected
                control.emblemClicked(index)
            }
        }

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
