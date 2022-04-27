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

    fillMode: control.fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop

    template.iconComponent: (model.format === "gif" || model.format === "avif" ) && control.hovered ? _animatedComponent :  _iconComponent

    Component
    {
        id: _iconComponent
        Maui.IconItem
        {
            id: _iconItem
            iconSource: control.iconSource
            imageSource: control.imageSource

            highlighted: control.isCurrentItem
            hovered: control.hovered
            smooth: control.smooth
            iconSizeHint: control.iconSizeHint
            imageSizeHint: control.imageSizeHint

            fillMode: control.fillMode
            maskRadius: control.maskRadius

            imageWidth: control.imageWidth
            imageHeight: control.imageHeight

            isMask: control.isMask
            image.autoTransform: true
            Component.onCompleted: control.label2.text =  Qt.binding(function () { return _iconItem.image.implicitWidth + " x " + _iconItem.image.implicitHeight})

        }
    }

    Component
    {
        id: _animatedComponent
        AnimatedImage
        {
            source: control.imageSource
            fillMode:  control.fillMode
            autoTransform: true
            asynchronous: true
            onStatusChanged: playing = (status == AnimatedImage.Ready)
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }
    }
}
