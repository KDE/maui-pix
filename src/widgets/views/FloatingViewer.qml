import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import org.mauikit.controls as Maui

Loader
{
    id: control
    active: _pixViewer.viewer.count > 0 || item
    visible: _pixViewer.viewer.count > 0

    asynchronous: true
    z:  Overlay.overlay.z
    x: parent.width - implicitWidth - 20
    y: parent.height - implicitHeight - 20


    ScaleAnimator on scale
    {
        from: 2
        to: 1
        duration: Maui.Style.units.longDuration
        running: control.visible
        easing.type: Easing.OutInQuad
    }

    OpacityAnimator on opacity
    {
        from: 0
        to: 1
        duration: Maui.Style.units.longDuration
        running: control.status === Loader.Ready || control.visible
    }

    sourceComponent: AbstractButton
    {
        id: _floatingViewer
        Maui.Controls.badgeText: _pixViewer.viewer.count

        padding: Maui.Style.defaultPadding

        implicitHeight: miniArtwork.paintedHeight + topPadding + bottomPadding
        implicitWidth: miniArtwork.paintedWidth + leftPadding + rightPadding

        hoverEnabled: !Maui.Handy.isMobile

        scale: hovered || pressed ? 1.2 : 1

        Behavior on scale
        {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Behavior on implicitHeight
        {
            NumberAnimation
            {
                duration: Maui.Style.units.shortDuration
                easing.type: Easing.InQuad
            }
        }

        onClicked:
        {
            if( _pixViewer.viewer.count > 0)
            {
                toggleViewer()
                return;
            }
        }

        background: Rectangle
        {
            color: "white"

            radius: Maui.Style.radiusV
            // property color borderColor: Maui.Theme.textColor
            // border.color: Maui.Style.trueBlack ? Qt.rgba(borderColor.r, borderColor.g, borderColor.b, 0.3) : undefined
            layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
            layer.effect: MultiEffect
            {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: "#000000"
            }
        }

        Loader
        {
            id: _badgeLoader

            z: _floatingViewer.contentItem.z + 9999
            asynchronous: true

            active: _floatingViewer.Maui.Controls.badgeText && _floatingViewer.Maui.Controls.badgeText.length > 0 && _floatingViewer.visible
            visible: active

            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: 10
            anchors.horizontalCenterOffset: -5

            sourceComponent: Maui.Badge
            {
                text: _floatingViewer.Maui.Controls.badgeText

                padding: 2
                font.pointSize: Maui.Style.fontSizes.tiny

                Maui.Controls.status: Maui.Controls.Negative

                OpacityAnimator on opacity
                {
                    from: 0
                    to: 1
                    duration: Maui.Style.units.longDuration
                    running: parent.visible
                }

                ScaleAnimator on scale
                {
                    from: 0.5
                    to: 1
                    duration: Maui.Style.units.longDuration
                    running: parent.visible
                    easing.type: Easing.OutInQuad
                }
            }
        }

        contentItem: Item
        {
            Image
            {
                id: miniArtwork
                source: _pixViewer.currentPic.url
                sourceSize.height: implicitHeight > implicitWidth ? 160 : -1
                sourceSize.width: implicitHeight < implicitWidth ? 160 : -1

                fillMode: Image.PreserveAspectFit

                Rectangle
                {
                    anchors.fill: parent
                    color: Maui.Theme.backgroundColor
                    opacity: 0.5
                    visible: _floatingViewer.hovered
                    Maui.Icon
                    {
                        anchors.centerIn: parent
                        source: "quickview"
                        height: 48
                        width: 48
                    }
                }

                layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software

                layer.effect: MultiEffect
                {
                    maskEnabled: true
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                    maskSpreadAtMax: 0.0
                    maskThresholdMax: 1.0
                    maskSource: ShaderEffectSource
                    {
                        sourceItem: Rectangle
                        {
                            width: miniArtwork.width
                            height: miniArtwork.height
                            radius:  Maui.Style.radiusV
                        }
                    }
                }
            }
        }
    }
}
