import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.kde.kquickimageeditor 1.0 as KQuickImageEditor
import QtGraphicalEffects 1.12

Maui.Page
{
    id: control
    property url url

    property bool ready : String(control.url).length

    headBar.visible: control.ready


    headBar.rightContent:  Maui.ToolActions
    {
        autoExclusive: false
        checkable: false
        Action
        {
            text: i18n("Save as")
            icon.name: "document-save-as"
        }

        Action
        {
            text: i18n("Save")
            icon.name: "document-save"
        }
    }

    headBar.leftContent: Maui.ToolActions
    {
        autoExclusive: false
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
            enabled: imageDoc.edited
        }
    }

    headBar.middleContent: Maui.ToolActions
    {
        id: _editTools
        autoExclusive: true
        currentIndex : 1
        display: ToolButton.TextBesideIcon

        Action
        {
            text: i18n("Color")
        }

        Action
        {
            text: i18n("Transform")
        }

        Action
        {
            text: i18n("Layer")
        }
    }

    KQuickImageEditor.ImageDocument
    {
        id: imageDoc
        path: control.url
    }

    footBar.visible: false
    footerColumn: [

        TransformationBar
        {
            id: _transBar
            visible: _editTools.currentIndex === 1 && control.ready
            width: parent.width
        },

        ColourBar
        {
            id: _colourBar
            visible: _editTools.currentIndex === 0 && control.ready
            width: parent.width
        }
    ]

    KQuickImageEditor.ImageItem
    {
        id: editImage
        fillMode: KQuickImageEditor.ImageItem.PreserveAspectFit
        image: imageDoc.image
        anchors.fill: parent
        rotation: _transBar.rotationSlider.value
    }

    Canvas {
        visible: _transBar.rotationButton.checked
        opacity: 0.15
        anchors.fill : parent
        property int wgrid: control.width / 20
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = 0.5
            ctx.strokeStyle = Kirigami.Theme.textColor
            ctx.beginPath()
            var nrows = height/wgrid;
            for(var i=0; i < nrows+1; i++){
                ctx.moveTo(0, wgrid*i);
                ctx.lineTo(width, wgrid*i);
            }

            var ncols = width/wgrid
            for(var j=0; j < ncols+1; j++){
                ctx.moveTo(wgrid*j, 0);
                ctx.lineTo(wgrid*j, height);
            }
            ctx.closePath()
            ctx.stroke()
        }
    }

    KQuickImageEditor.ResizeRectangle
    {
        id: resizeRectangle

        visible: _transBar.cropButton.checked

        width: editImage.paintedWidth
        height: editImage.paintedHeight
        anchors.centerIn: parent
        insideX: 100
        insideY: 100
        insideWidth: 100
        insideHeight: 100

        onAcceptSize: control.crop();

        //resizeHandle: KQuickImageEditor.BasicResizeHandle { }

        /*Rectangle {
            radius: 2
            width: Kirigami.Units.gridUnit * 8
            height: Kirigami.Units.gridUnit * 3
            anchors.centerIn: parent
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            color: Kirigami.Theme.backgroundColor
            QQC2.Label {
                anchors.centerIn: parent
                text: "x: " + (resizeRectangle.x - control.contentItem.width + editImage.paintedWidth)
                    + " y: " +  (resizeRectangle.y - control.contentItem.height + editImage.paintedHeight)
                    + "\nwidth: " + resizeRectangle.width
                    + " height: " + resizeRectangle.height
            }
        }*/
    }

    function crop() {
        console.log("CROP")
        const ratioX = editImage.paintedWidth / editImage.nativeWidth;
        const ratioY = editImage.paintedHeight / editImage.nativeHeight;
        _transBar.cropButton.checked= false
        imageDoc.crop(resizeRectangle.insideX / ratioX, resizeRectangle.insideY / ratioY, resizeRectangle.insideWidth / ratioX, resizeRectangle.insideHeight / ratioY);
    }
}
