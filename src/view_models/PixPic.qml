import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.GridBrowserDelegate
{
    id: control

    property bool fit : false

    draggable: true

    tooltipText: model.url
    iconSizeHint: Maui.Style.iconSizes.small

    label1.text: model.title

    iconSource: "image-x-generic"
    imageSource: model.url
    template.fillMode: control.fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop
    template.autoTransform: true
}
