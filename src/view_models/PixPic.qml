import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.GridBrowserDelegate
{
    id: control

    property bool fit : false

    draggable: true

    template.maskRadius: radius
    tooltipText: model.url
    iconSizeHint: showLabel ? height * 0.6 : height

    template.imageHeight: height
    template.imageWidth: height
    label1.text: model.title

    imageSource: (model.url && model.url.length>0) ? model.url : "qrc:/assets/image-x-generic.svg"
    template.fillMode: control.fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop
}
