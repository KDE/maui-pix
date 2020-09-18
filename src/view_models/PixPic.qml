import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ItemDelegate
{
    id: control

    property alias checked : _template.checked
    property alias checkable: _template.checkable

    property alias labelsVisible: _template.labelsVisible
    property alias imageBorder: _template.imageBorder

    property bool fit : false
    signal toggled(int index, bool state);

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered
    ToolTip.text: model.url

    radius: Maui.Style.radiusV

    draggable: true
    background: Item {}

    Maui.GridItemTemplate
    {
        id: _template
        anchors.fill: parent
        maskRadius: control.radius
        isCurrentItem: control.isCurrentItem       
        iconSizeHint: labelsVisible ? height * 0.6 : height
        imageHeight: height
        imageWidth: height
        label1.text: model.title

        imageSource: (model.url && model.url.length>0) ? model.url : "qrc:/assets/image-x-generic.svg"
        fillMode: control.fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop
        hovered: control.hovered
        onToggled: control.toggled(index, state)
    }
}
