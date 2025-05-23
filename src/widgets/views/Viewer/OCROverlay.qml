import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.imagetools as IT
import org.mauikit.filebrowsing as FB

Item
{
    opacity: 0.5
    Keys.enabled: true
    Keys.onPressed: (event) =>
                    {
                        if(event.key === Qt.Key_Escape && _boxes.selectedIndexes.length > 0)
                        {
                            _boxes.reset()
                            event.accepted = true
                        }

                        if(event.key === Qt.Key_A && (event.modifiers & Qt.ControlModifier))
                        {
                            selectAll()
                            event.accepted = true
                        }
                    }

    function selectAll()
    {
        _boxes.selectedIndexes = _ocr.allWordBoxes()
        setSelectedIndexes()
        _boxes.selectAll()
    }

    Maui.ContextualMenu
    {
        id: _selectionMenu

        MenuItem
        {
            action: _copyAction
        }

        Action
        {
            text: i18n("Select All")
            onTriggered: selectAll()
        }

        MenuItem
        {
            text: i18n("Call")
            enabled: Maui.Handy.isPhoneNumber(control.textSelected)
            visible: enabled
            height: visible ? implicitHeight : -_selectionMenu.spacing
            onTriggered: Qt.openUrlExternally("tel:"+control.textSelected)
        }

        MenuItem
        {
            enabled: Maui.Handy.isPhoneNumber(control.textSelected) || Maui.Handy.isEmail(control.textSelected)
            visible: enabled
            height: visible ? implicitHeight : -_selectionMenu.spacing
            text: i18n("Save as Contact")
            icon.name: "contact-new-symbolic"
            onTriggered: Qt.openUrlExternally("tel:"+control.textSelected)
        }

        MenuItem
        {
            text: i18n("Message")
            enabled: Maui.Handy.isPhoneNumber(control.textSelected) || Maui.Handy.isEmail(control.textSelected)
            visible: enabled
            icon.name: "mail-message-new"
            height: visible ? implicitHeight : -_selectionMenu.spacing
            onTriggered: Qt.openUrlExternally("mailto:"+control.textSelected)
        }

        MenuItem
        {
            enabled: Maui.Handy.isWebLink(control.textSelected)
            visible: enabled
            height: visible ? implicitHeight : -_selectionMenu.spacing
            text: i18n("Open Link")
            icon.name: "website-symbolic"
            onTriggered: Qt.openUrlExternally(control.textSelected)
        }

        MenuItem
        {
            enabled: Maui.Handy.isTimeDate(control.textSelected)
            visible: enabled
            height: visible ? implicitHeight : -_selectionMenu.spacing
            text: i18n("Create Event")
            icon.name: "tag-events"
            onTriggered: Qt.openUrlExternally(control.textSelected)
        }

        MenuItem
        {
            text: i18n("Save to Note")
            icon.name:"note"
            onTriggered: Collection.createNote(control.textSelected)
        }

        MenuItem
        {
            text: i18n("Search Selected Text on Google...")
            visible: enabled
            icon.name: "find"
            height: visible ? implicitHeight : -_selectionMenu.spacing
            onTriggered: Qt.openUrlExternally("https://www.google.com/search?q="+control.textSelected)
        }
    }

    Item
    {
        id: _boxes
        anchors.fill: parent

        property var selectedText: []
        property var selectedIndexes: []

        signal resetSelection();
        signal selectAll()

        function reset()
        {
            _boxes.resetSelection()
            _boxes.selectedText = []
            _boxes.selectedIndexes = []
            textSelected = ""
        }

        Repeater
        {
            id: _repeater
            // model: _ocr.wordBoxes
            model: switch(viewerSettings.ocrBlockType)
                   {
                   case 0: return _ocr.wordBoxes;
                   case 1: return _ocr.paragraphBoxes;
                   case 2: return _ocr.lineBoxes;
                   default: return _ocr.wordBoxes;
                   }

            // model: _ocr.lineBoxes

            delegate: MouseArea
            {
                id: _mouseArea
                clip: false
                hoverEnabled: !Maui.Handy.isMobile
                x: parent.width * modelData.rect.x / _imgV.image.implicitWidth
                y: parent.height * modelData.rect.y / _imgV.image.implicitHeight
                width: parent.width * modelData.rect.width / _imgV.image.implicitWidth
                height: parent.height * modelData.rect.height / _imgV.image.implicitHeight
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.RightButton

                property bool selected  : false
                readonly property string text : modelData.text

                Connections
                {
                    target: _boxes
                    function onResetSelection()
                    {
                        selected = false
                    }

                    function onSelectAll()
                    {
                        selected = true
                    }
                }

                Rectangle
                {
                    id: _highlightRec
                    height: parent.height + 6
                    width: parent.width+6
                    anchors.centerIn: parent
                    radius: 0
                    // color: Maui.Theme.linkBackgroundColor
                    visible: opacity > 0

                    Behavior on opacity
                    {
                        NumberAnimation
                        {
                            duration: Maui.Style.units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    ColorAnimation on color
                    {
                        from: "transparent"
                        to: Maui.Theme.linkBackgroundColor
                        duration: Maui.Style.units.longDuration
                        // running: _ocr.ready
                        easing.type: Easing.InOutQuad
                        onFinished:
                        {
                            _highlightRec.opacity = Qt.binding( ()=>{ return _mouseArea.containsMouse || _mouseArea.selected ? 0.7 : 0} )
                        }
                    }
                }

                onClicked: (mouse) =>
                           {
                               if(mouse.button == Qt.RightButton)
                               {
                                   if(_boxes.selectedIndexes.indexOf(index) < 0)
                                   {
                                       _boxes.reset()
                                   }

                                   selected = true
                                   control.textSelected = control.textSelected.length > 0 ? control.textSelected : modelData.text
                                   _selectionMenu.show()
                               }
                           }

                // Connections
                // {
                // }

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: _mouseArea.containsMouse
                ToolTip.text: control.textSelected .length && _boxes.selectedIndexes.indexOf(index) >= 0 ? control.textSelected : modelData.text
            }
        }
    }

    MouseArea
    {
        id: _selectionArea
        enabled: !Maui.Handy.isMobile && viewerList.shiftPressed && !_imgV.zooming && _repeater.count > 0
        visible: enabled
        anchors.fill: parent

        preventStealing: false
        propagateComposedEvents: true
        cursorShape: viewerList.shiftPressed && enabled ? Qt.IBeamCursor : undefined
        acceptedButtons: Qt.LeftButton

        property var pressedPosition


        onClicked:(mouse) => mouse.accepted= false

        onEnabledChanged: if(enabled) _boxes.reset()

        onPressed: (mouse) =>
                   {
                       console.log(mouse.modifiers === Qt.NoModifier)
                       if (mouse.modifiers === Qt.NoModifier)
                       {
                           _boxes.reset()
                       }

                       pressedPosition = Qt.point(mouse.x, mouse.y)
                   }

        onReleased: (mouse) =>
                    {
                        setSelectedIndexes()
                        mouse.accepted = false
                    }

        onPositionChanged: (mouse) =>
                           {
                               if(Math.round(mouse.x)%2 === 0 || Math.round(mouse.y)%2 === 0)
                               {
                                   if(_selectionArea.containsPress && mouse.modifiers === Qt.ShiftModifier)
                                   {
                                       if(viewerSettings.ocrSelectionType === 0)
                                       {
                                           console.log("Selection tool",pressedPosition, mouse.x, mouse.y)
                                           let point = mapPoint(Qt.point(mouse.x, mouse.y))
                                           let index = _ocr.wordBoxAt(point)
                                           let box = _repeater.itemAt(index)
                                           if(box)
                                           {
                                               if(_boxes.selectedIndexes.indexOf(index) < 0)
                                               {
                                                   box.selected = true
                                                   _boxes.selectedIndexes.push(index)
                                               }
                                               console.log(index, box.text, box.selected)
                                           }
                                       }else
                                       {
                                           _boxes.resetSelection()
                                           let point2 = mapPoint(Qt.point(mouse.x, mouse.y))
                                           let point1 = mapPoint(_selectionArea.pressedPosition)

                                           let rect = Qt.rect(point1.x, point1.y, Math.abs(point2.x-point1.x), Math.abs(point2.y-point1.y))

                                           _boxes.selectedIndexes = _ocr.wordBoxesAt(rect)
                                           console.log("Selected rect:" , rect, _boxes.selectedIndexes)

                                           for(var i of _boxes.selectedIndexes)
                                           {
                                               let box = _repeater.itemAt(i)
                                               if(box)
                                               {
                                                   box.selected = true
                                               }
                                           }
                                       }
                                   }
                               }
                           }

        function mapPoint(point)
        {
            return Qt.point(_imgV.image.implicitWidth * point.x / _selectionArea.width, _imgV.image.implicitHeight * point.y/ _selectionArea.height);
        }
    }
    function setSelectedIndexes()
    {
        _boxes.selectedText = []
        _boxes.selectedIndexes.sort(function(a, b) {
            return a - b;
        })
        console.log("Selected indexes sorted", _boxes.selectedIndexes)
        for(var i of _boxes.selectedIndexes)
        {
            _boxes.selectedText.push(_repeater.itemAt(i).text)
        }

        textSelected = _boxes.selectedText.length > 0 ? _boxes.selectedText.join(" ") : ""
    }

    IT.OCR
    {
        id: _ocr
        filePath: model.url
        autoRead: true
        boxesType: switch(viewerSettings.ocrBlockType)
                   {
                   case 0: return IT.OCR.Word;
                   case 1: return IT.OCR.Line;
                   case 2: return IT.OCR.Paragraph;
                   default: return IT.OCR.Word;
                   }

        confidenceThreshold: 40
        preprocessImage: viewerSettings.ocrPreprocessing
        pageSegMode: viewerSettings.ocrSegMode
    }
}
