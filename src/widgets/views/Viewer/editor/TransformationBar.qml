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

    property alias rotationSlider: _freeRotationSlider
    property alias rotationButton : _freeRotationButton
    property alias cropButton : _cropButton

    Maui.ToolBar
    {
        position: ToolBar.Footer
        Layout.fillWidth: true
        visible: _freeRotationButton.checked
        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
        }
        leftContent: [
            ToolButton
            {
                icon.name: "object-flip-vertical"
                text: i18nc("@action:button Mirror an image vertically", "Flip");
                autoExclusive: true
                onClicked: imageDoc.mirror(false, true);
            },

            ToolButton
            {
                icon.name: "object-flip-horizontal"
                text: i18nc("@action:button Mirror an image horizontally", "Mirror");
                checkable: true
                autoExclusive: true
                onClicked: imageDoc.mirror(true, false);
            }

        ]

        rightContent: ToolButton
        {
            icon.name: "object-rotate-left"
            //                    display: ToolButton.IconOnly
            text: i18nc("@action:button Rotate an image 90°", "Rotate 90°");
            onClicked:
            {
                let value = _freeRotationSlider.value-90
                _freeRotationSlider.value = value < -180 ? 90 : value
            }
        }

        //                middleContent: Label
        //                {
        //                    text: i18n("Rotate")
        //                }
    }

    Maui.ToolBar
    {
        id: _freeRotation

        visible: _freeRotationButton.checked
        position: ToolBar.Footer
        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
        }

        Layout.fillWidth: true


        middleContent: Ruler
        {
            id: _freeRotationSlider
            Layout.fillWidth: true
            from : -180
            to: 180
            value: 0
            snapMode: Slider.SnapAlways
            stepSize: 1
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
                id: _cropButton
                checkable: true
                autoExclusive: true
                icon.name:  "transform-crop"
                text:  i18nc("@action:button Crop an image", "Crop");
            },

            ToolButton
            {
                id: _freeRotationButton
                autoExclusive: true
                icon.name: "transform-rotate"
                checkable: true
                text: i18nc("@action:button Rotate an image", "Rotate");
            }
        ]

        leftContent: ToolButton
        {
            //                    text: i18n("Accept")
            visible: _freeRotationButton.checked || _cropButton.checked

            icon.name: "checkmark"
            onClicked:
            {
                if(_freeRotationButton.checked)
                {
                    var value = _freeRotationSlider.value
                    _freeRotationSlider.value = 0

                    console.log("Rotate >> " , value)
                    imageDoc.rotate(value);
                }

                if(_cropButton.checked)
                {
                    crop()
                }
            }
        }

        rightContent:  ToolButton
        {
            //                    text: i18n("Cancel")
            visible: _freeRotationButton.checked || _cropButton.checked
            icon.name: "dialog-cancel"
            onClicked:
            {
                if(_freeRotationButton.checked)
                {
                    _freeRotationSlider.value = 0
                    _freeRotationButton.checked = false

                }

                if(_cropButton.checked)
                {
                    _cropButton.checked = false
                }
            }
        }
    }
}

