import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.kde.kquickimageeditor 1.0 as KQuickImageEditor

Maui.Page
{
    id: control
    property url url
    property bool resizing : false

    title: i18n("Edit")
    leftPadding: 0
    rightPadding: 0

    headBar.farLeftContent: ToolButton
    {
        icon.name: "go-previous"
        onClicked: control.parent.pop()
    }

    headBar.rightContent: Maui.ToolActions
    {
        autoExclusive: false
        checkable: false
        expanded: true

        Action
        {
            text: qsTr("Save")
            icon.name: "document-save"
        }

        Action
        {
            icon.name: "document-save-as"
            text: qsTr("Save as...")
        }
    }

    footBar.leftContent: Maui.ToolActions
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

    footBar.rightContent: [
        ToolButton
        {
            icon.name: "draw-freehand"
            onClicked:
            {
                    _doodleDialog.sourceItem = editImage
                    _doodleDialog.open()
            }
        }
    ]

    footBar.middleContent: [

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

    MauiLab.Doodle
    {
        id: _doodleDialog
    }


    KQuickImageEditor.ImageDocument
    {
        id: imageDoc
        path: control.url
    }


    Flickable
    {
        anchors.fill: parent
        KQuickImageEditor.ImageItem
        {
            id: editImage
            fillMode: KQuickImageEditor.ImageItem.PreserveAspectFit
            image: imageDoc.image
            anchors.fill: parent
        }
    }

    KQuickImageEditor.ResizeRectangle
    {
        id: resizeRectangle

        visible: control.resizing

        width: 300
        height: 300
        x: 200
        y: 200

        onAcceptSize: crop();

        Rectangle {
            color: "#3daee9"
            opacity: 0.6
            anchors.fill: parent
        }

        KQuickImageEditor.BasicResizeHandle {
            rectangle: resizeRectangle
            resizeCorner: KQuickImageEditor.ResizeHandle.TopLeft
            anchors {
                horizontalCenter: parent.left
                verticalCenter: parent.top
            }
        }
        KQuickImageEditor.BasicResizeHandle {
            rectangle: resizeRectangle
            resizeCorner: KQuickImageEditor.ResizeHandle.BottomLeft
            anchors {
                horizontalCenter: parent.left
                verticalCenter: parent.bottom
            }
        }
        KQuickImageEditor.BasicResizeHandle {
            rectangle: resizeRectangle
            resizeCorner: KQuickImageEditor.ResizeHandle.BottomRight
            anchors {
                horizontalCenter: parent.right
                verticalCenter: parent.bottom
            }
        }
        KQuickImageEditor.BasicResizeHandle {
            rectangle: resizeRectangle
            resizeCorner: KQuickImageEditor.ResizeHandle.TopRight
            anchors {
                horizontalCenter: parent.right
                verticalCenter: parent.top
            }
        }
    }
}
