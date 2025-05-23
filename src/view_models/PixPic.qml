import QtQuick
import QtQuick.Controls
import QtMultimedia

import org.mauikit.controls as Maui

Maui.GridBrowserDelegate
{
    id: control

    property bool fit : false

    maskRadius: 0
    draggable: true

    tooltipText: model.url
    iconSizeHint: Maui.Style.iconSizes.small

    label1.text: model.title

    iconSource: "image-x-generic"
    imageSource: model.url

    fillMode: control.fit ? Image.PreserveAspectFit : Image.PreserveAspectCrop
    template.labelSizeHint: 40
    //    template.alignment: Qt.AlignLeft
    template.iconComponent: (model.format === "gif" || model.format === "avif") && control.hovered ? _animatedComponent :  _iconComponent

    Loader
    {
        asynchronous: true
        active: (model.format === "gif" || model.format === "avif") && !control.hovered
        anchors.centerIn: parent
        height: 32
        width: 32

        sourceComponent: Rectangle
        {
            color: Maui.Theme.backgroundColor
            radius: height/2

            Maui.Icon
            {
                source: "media-playback-start"
                color : Maui.Theme.textColor
                height: 16
                width: 16
                anchors.centerIn: parent
            }
        }
    }

    Component
    {
        id: _iconComponent

        Maui.IconItem
        {
            id: _iconItem
            iconSource: control.iconSource
            imageSource: model.url

            highlighted: control.isCurrentItem
            hovered: control.hovered
            smooth: control.smooth
            iconSizeHint: control.iconSizeHint
            imageSizeHint: control.imageSizeHint

            fillMode: control.fillMode
            maskRadius: control.maskRadius

            imageWidth: control.imageWidth
            imageHeight: control.imageHeight

            isMask: true
            image.autoTransform: true
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
