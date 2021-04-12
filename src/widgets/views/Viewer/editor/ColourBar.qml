import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.kde.kquickimageeditor 1.0 as KQuickImageEditor
import QtGraphicalEffects 1.12

ColumnLayout
{
    id: control

    spacing: 0

    property alias brightnessButton: _brightnessButton
    property alias contrastButton : _contrastButton
    property alias saturationButton : _saturationButton


    Maui.ToolBar
    {
        id: _sliderToolBar
        Layout.fillWidth: true
        middleContent:  Slider
        {
            id: _slider
            Layout.fillWidth: true
            value: 0
            from: -100
            to: 100
            stepSize: 1
        }

        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
        }
    }

    Maui.ToolBar
    {
        position: ToolBar.Footer
        Layout.fillWidth: true

        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
        }

        middleContent: [
            ToolButton
            {
                id: _saturationButton
                checkable: true
                autoExclusive: true
                icon.name:  "transform-crop"
                text:  i18nc("@action:button Crop an image", "Saturation");
            },

            ToolButton
            {
                id: _contrastButton
                autoExclusive: true
                icon.name: "transform-rotate"
                checkable: true
                text: i18nc("@action:button Rotate an image", "Contrast");
            }  ,

            ToolButton
            {
                id: _exposureButton
                autoExclusive: true
                icon.name: "transform-rotate"
                checkable: true
                text: i18nc("@action:button Rotate an image", "Exposure");
            },

            ToolButton
            {
                id: _highlightsButton
                autoExclusive: true
                icon.name: "transform-rotate"
                checkable: true
                text: i18nc("@action:button Rotate an image", "Highlights");
            },

            ToolButton
            {
                id: _shadowsButton
                autoExclusive: true
                icon.name: "transform-rotate"
                checkable: true
                text: i18nc("@action:button Rotate an image", "Shadows");
            },


            ToolButton
            {
                id: _brightnessButton
                autoExclusive: true
                icon.name: "transform-rotate"
                checkable: true
                text: i18nc("@action:button Rotate an image", "Brightness");
            }
        ]

        leftContent: ToolButton
        {
            //                    text: i18n("Accept")
            icon.name: "dialog-apply"
            onClicked:
            {

            }
        }

        rightContent:  ToolButton
        {
            //                    text: i18n("Cancel")
            icon.name: "dialog-cancel"
            onClicked:
            {
            }
        }
    }
}

