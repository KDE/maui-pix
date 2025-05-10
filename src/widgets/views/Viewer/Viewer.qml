// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.imagetools as IT
import org.mauikit.filebrowsing as FB

import org.maui.pix

import "../../"

Item
{
    id: control

    property bool autoSaveTransformation : false
    property real picContrast : 0
    property real picBrightness : 0
    property real picSaturation : 0
    property real picHue : 0
    property real picLightness : 0
    readonly property alias model : pixModel

    readonly property alias count : viewerList.count
    readonly property alias currentIndex : viewerList.currentIndex
    readonly property alias currentItem: viewerList.currentItem

    property string textSelected
    /**
      * Whether the current image is zomming in
      **/
    readonly property bool imageZooming : currentItem ? currentItem.zooming : false

    /**
      *Whether the current image is an animated image such as a gid or avif format
      **/
    readonly property bool isAnimated : currentItem ? currentItem.isAnimated : false

    clip: false
    focus: true
    focusPolicy: Qt.StrongFocus

    Keys.enabled: true
    Keys.forwardTo: viewerList

    Maui.BaseModel
    {
        id: pixModel
        list: GalleryList
        {
            autoReload: browserSettings.autoReload
            activeGeolocationTags: false
        }

        sort: browserSettings.sortBy
        sortOrder: browserSettings.sortOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    function forceActiveFocus()
    {
        viewerList.forceActiveFocus()
    }

    function reloadCurrentItem()
    {
        control.currentItem.active = false
        control.currentItem.active = true
    }

    Action
    {
        id: _copyAction
        shortcut: "Ctrl+c"
        text: "Copy"
        onTriggered:
        {
            if(control.textSelected.length>0)
            {
                Maui.Handy.copyTextToClipboard(control.textSelected)
                Maui.App.rootComponent.notify("dialog-info", i18n("Text copied!"), control.textSelected)
            }else
            {
                Maui.Handy.copyToClipboard({"urls": [currentPic.url]}, false)
                Maui.App.rootComponent.notify(currentPic.url, i18n("Image file copied!"))
            }
        }
    }

    Maui.ContextualMenu
    {
        id: _selectionMenu

        MenuItem
        {
            action: _copyAction
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

    ListView
    {
        id: viewerList
        height: parent.height
        width: parent.width
        orientation: ListView.Horizontal

        Binding on currentIndex
        {
            value: currentPicIndex
            restoreMode: Binding.RestoreBindingOrValue
        }

        focus: true
        interactive: Maui.Handy.isTouch
        cacheBuffer: width * 3
        model: pixModel
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds

        preferredHighlightBegin: 0
        preferredHighlightEnd: width

        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 0
        highlightFollowsCurrentItem: true
        highlightResizeDuration: 0
        highlightMoveVelocity: -1
        highlightResizeVelocity: -1

        maximumFlickVelocity: 4 * (viewerList.orientation === Qt.Horizontal ? width : height)
        property bool shiftPressed : false

        Keys.enabled: true
        Keys.onPressed: (event) =>
                        {
                            console.log("key pressed", event.key, event.key == Qt.Key_Control )
                            if(event.key === Qt.Key_Shift)
                            {
                                console.log("shift pressed")
                                shiftPressed = true
                                event.accepted = true
                                return
                            }

                            if((event.key === Qt.Key_Right))
                            {
                                next()
                                event.accepted = true
                                return
                            }

                            if((event.key === Qt.Key_Left))
                            {
                                previous()
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_E && (event.modifiers & Qt.ControlModifier))
                            {
                                openEditor(currentPic.url, _stackView)
                                event.accepted = true
                            }

                            if(event.key === Qt.Key_S && (event.modifiers & Qt.ControlModifier))
                            {
                                saveAs([currentPic.url])
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_O && (event.modifiers & Qt.ControlModifier))
                            {
                                openFileWith([currentPic.url])
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_Space)
                            {
                                getFileInfo(currentPic.url)
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier))
                            {
                                removeFiles([currentPic.url])
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_S)
                            {
                                selectItem(currentPic)
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_F)
                            {
                                FB.Tagging.toggleFav(currentPic.url)
                                event.accepted = true
                                return
                            }

                            event.accepted = false
                        }

        Keys.onReleased:(event)=>
                        {
                            if(event.key == Qt.Key_Shift)
                            {
                                console.log("shift released")

                                shiftPressed = false
                                event.accepted = true
                                return
                            }
                            event.accepted = false
                        }


        onCurrentIndexChanged: viewerList.forceActiveFocus()

        onMovementEnded:
        {
            const index = indexAt(contentX, contentY)
            if(index !== currentPicIndex)
                view(index)
        }

        delegate: Loader
        {
            id: _viewerLoaderDelegate

            height: ListView.view.height
            width: ListView.view.width
            readonly property bool isCurrentItem: ListView.isCurrentItem
            readonly property bool zooming: item.zooming
            readonly property bool isAnimated : model.format === "gif" || model.format === "avif"
            //            active : ListView.isCurrentItem
            asynchronous: true

            sourceComponent: isAnimated ? _animatedImgComponent : _imgComponent

            Component
            {
                id: _animatedImgComponent
                Maui.AnimatedImageViewer
                {
                    property bool zooming : false
                    source: model.url
                }
            }

            Component
            {
                id: _imgComponent

                IT.ImageViewer
                {
                    id: _imgV
                    source: model.url
                    image.autoTransform: true
                    image.cache: false

                    readonly property bool imageReady: _imgV.image.status == Image.Ready

                    Timer
                    {
                        id: _timer
                        property bool ready : false
                        interval: 1500
                        running: imageReady && _viewerLoaderDelegate.isCurrentItem && !ready && viewerSettings.enableOCR
                        onTriggered:
                        {
                            console.log("Start OCR")
                            ready = true
                        }
                    }

                    Loader
                    {
                        active: (_viewerLoaderDelegate.isCurrentItem && viewerSettings.enableOCR && _timer.ready) || item
                        parent:  _imgV.image
                        height: _imgV.image.paintedHeight
                        width:  _imgV.image.paintedWidth
                        anchors.centerIn:  parent
                        visible: active && viewerSettings.enableOCR
                        sourceComponent: Item
                        {
                            opacity: 0.5
                            Keys.enabled: true
                            Keys.onEscapePressed: _boxes.reset()

                            Item
                            {
                                id: _boxes
                                anchors.fill: parent

                                property var selectedText: []
                                property var selectedIndexes: []

                                signal resetSelection();

                                function reset()
                                {
                                    _boxes.resetSelection()
                                    _boxes.selectedText = []
                                    _boxes.selectedIndexes = []
                                    control.textSelected = ""
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
                                                           _boxes.reset()

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
                                                _boxes.selectedText = []
                                                _boxes.selectedIndexes.sort(function(a, b) {
                                                    return a - b;
                                                })
                                                console.log("Selected indexes sorted", _boxes.selectedIndexes)
                                                for(var i of _boxes.selectedIndexes)
                                                {
                                                    _boxes.selectedText.push(_repeater.itemAt(i).text)
                                                }

                                                control.textSelected = _boxes.selectedText.length > 0 ? _boxes.selectedText.join(" ") : ""
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
                    }
                }
            }
        }
    }
    // MouseArea
    // {
    //     enabled: viewerSettings.previewBarVisible && galleryRoll.rollList.count > 1
    //     anchors.fill: parent
    //     onPressed: (mouse) =>
    //                {
    //                    galleryRollBg.visible = !galleryRollBg.visible
    //                    mouse.accepted = false
    //                }
    //     propagateComposedEvents: true
    //     preventStealing: false
    // }

    function appendPics(pics)
    {
        if(pics.length > 0)
            for(var i in pics)
                control.model.list.append(pics[i])

    }

    function clear()
    {
        control.model.list.clear()
    }
}
