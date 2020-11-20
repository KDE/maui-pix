// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.2 as Maui
//import org.kde.kquickimageeditor 1.0 as KQuickImageEditor

Maui.Page
{
    id: control
    property url url
    property bool resizing : false

    leftPadding: 0
    rightPadding: 0

    headBar.farLeftContent: [
        ToolButton
        {
            icon.name: "go-previous"
            onClicked: control.parent.pop()
        },

        Maui.ToolActions
        {
            expanded: true
            autoExclusive: true
            checkable: false

            Action
            {
                icon.name: "edit-undo"
                onTriggered: imageDoc.undo();
                enabled: imageDoc.edited
            }

            Action
            {
                icon.name: "edit-redo"
            }
        }
    ]

    headBar.rightContent: Maui.ToolActions
    {
        autoExclusive: false
        checkable: false
        expanded: true

        Action
        {
            text: i18n("Save")
            icon.name: "document-save"
        }

        Action
        {
            icon.name: "document-save-as"
            text: i18n("Save as...")
        }
    }


    //    Kirigami.Action {
    //                           iconName: rootEditorView.resizing ? "dialog-cancel" : "transform-crop"
    //                           text: rootEditorView.resizing ? i18n("Cancel") : i18nc("@action:button Crop an image", "Crop");
    //                           onTriggered: rootEditorView.resizing = !rootEditorView.resizing;
    //                       },
    //    Kirigami.Action {
    //        iconName: "dialog-ok"
    //        visible: rootEditorView.resizing
    //        text: i18nc("@action:button Rotate an image to the right", "Crop");
    //        onTriggered: rootEditorView.crop();
    //    },

    //    footBar.rightContent: [
    //        ToolButton
    //        {
    //            icon.name: "draw-freehand"
    //            onClicked:
    //            {
    //                _doodleDialog.sourceItem = editImage
    //                _doodleDialog.open()
    //            }
    //        }
    //    ]

    footBar.middleContent:
        [

        Maui.ToolActions
        {

            id: _editBar
            expanded: true
            autoExclusive: true
            checkable: false
            display: ToolButton.TextBesideIcon

        Action
        {
            icon.name: "configure"
                text: _editBar.currentIndex
//            checkable: true
//            checked: _transformBar.visible
//            onTriggered: _transformBar.visible = !_transformBar.visible
        }

        Action
        {
            icon.name: "edit-opacity"
//            checkable: true
//            checked: _colorBar.visible
//            onTriggered: _colorBar.visible = !_colorBar.visible
        }

        Action
        {
            icon.name: "layer-visible-on"
//            checkable: true
//            checked: _transformBar.visible
//            onClicked: _transformBar.visible = !_transformBar.visible
        }
        }
    ]

    footerColumn: [

        Maui.ToolBar
        {
            visible: _freeRotation.checked
            width: parent.width

            leftContent: ToolButton
            {
                icon.name: "checkmark"
                onClicked:
                {
                    _freeRotation.checked = false
                    imageDoc.rotate(_freeRotationSlider.value)
                    _freeRotationSlider.value = 0
                }
            }

            rightContent: ToolButton
            {
                icon.name: "edit-delete-remove"
            }

            middleContent: Slider
            {
                id: _freeRotationSlider

                Layout.fillWidth: true
                from: -180
                to: 180
                value: 0
                stepSize: 1
                snapMode: Slider.SnapOnRelease

//                onValueChanged: imageDoc.rotate(value)
            }
        },

        Maui.ToolBar
        {
            id: _colorBar
            visible: _editBar.currentIndex === 1
            position: ToolBar.Footer
            width: parent.width
            middleContent: [

                RoundButton
                {
                    icon.name: "contrast"
                },

                RoundButton
                {
                    icon.name: "tool_flood_fill"
                },

                RoundButton
                {
                    icon.name: "layer-visible-on"
                }
            ]
        },

        Maui.ToolBar
        {
            id: _transformBar
            visible: _editBar.currentIndex === 0
            position: ToolBar.Footer
            width: parent.width
            middleContent: [

                ToolButton
                {
                    id: _freeRotation
                    checkable: true
                    checked: false
                    icon.name: "transform-rotate"
                    text: i18n("Free rotation")
                },

                Maui.ToolActions
                {
                    expanded: true
                    autoExclusive: false
                    checkable: false
                    display: ToolButton.TextBesideIcon

                    Action
                    {
                        icon.name: "object-rotate-left"
                        text: i18nc("@action:button Rotate an image to the left", "Rotate left");
                        onTriggered: imageDoc.rotate(-90);
                        enabled: !control.resizing
                    }

                    Action
                    {
                        icon.name: "object-rotate-right"
                        text: i18nc("@action:button Rotate an image to the right", "Rotate right");
                        onTriggered: imageDoc.rotate(90);
                        enabled: !control.resizing
                    }
                },

                Maui.ToolActions
                {
                    expanded: true
                    autoExclusive: false
                    checkable: false
                    display: ToolButton.TextBesideIcon

                    Action
                    {
                        icon.name: "object-flip-vertical"
                        text: i18nc("@action:button Mirror an image vertically", "Flip");
                        onTriggered: imageDoc.mirror(false, true);
                        enabled: !control.resizing
                    }

                    Action
                    {
                        icon.name: "object-flip-horizontal"
                        text: i18nc("@action:button Mirror an image horizontally", "Mirror");
                        onTriggered: imageDoc.mirror(true, false);
                        enabled: !control.resizing
                    }
                },

                Maui.ToolActions
                {
                    expanded: true
                    autoExclusive: false
                    checkable: false
                    display: ToolButton.TextBesideIcon

                    Action
                    {
                        icon.name: control.resizing ? "dialog-cancel" : "transform-crop"
                        text: control.resizing ? i18n("Cancel") : i18nc("@action:button Crop an image", "Crop");
                        onTriggered: control.resizing = !control.resizing;
                    }
                }
            ]
        }]

    //    MauiLab.Doodle
    //    {
    //        id: _doodleDialog
    //    }


//    KQuickImageEditor.ImageDocument
//    {
//        id: imageDoc
//        path: control.url
//    }


    Flickable
    {
        anchors.fill: parent
//        KQuickImageEditor.ImageItem
//        {
//            id: editImage
//            rotation: _freeRotation.checked ? _freeRotationSlider.value : 0
//            fillMode: KQuickImageEditor.ImageItem.PreserveAspectFit
//            image: imageDoc.image
//            anchors.fill: parent
//        }
    }

//    Item
//    {
//        id: _grid

//        Column
//    }

//    KQuickImageEditor.ResizeRectangle
//    {
//        id: resizeRectangle
//        anchors.centerIn: parent
//        visible: control.resizing

//        width: editImage.paintedWidth
//        height: editImage.paintedHeight
//        x: 0
//        y: editImage.verticalPadding

//        insideX: 100
//        insideY: 100
//        insideWidth: 100
//        insideHeight: 100

//        onAcceptSize: control.crop();
//    }

    function crop()
    {
        const ratioX = editImage.paintedWidth / editImage.nativeWidth;
        const ratioY = editImage.paintedHeight / editImage.nativeHeight;
        control.resizing = false
        imageDoc.crop((resizeRectangle.insideX - control.contentItem.width + editImage.paintedWidth) / ratioX, (resizeRectangle.insideY - control.contentItem.height + editImage.paintedHeight) / ratioY, resizeRectangle.insideWidth / ratioX, resizeRectangle.insideHeight / ratioY);
    }
}
