// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQml
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.imagetools as IT

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

    clip: false
    focus: true

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



    Maui.ContextualMenu
    {
        id: _selectionMenu

        property string text

        MenuItem
        {
            text: i18n("Copy")
            onTriggered: Maui.Handy.copyTextToClipboard(_selectionMenu.text)
        }

        MenuItem
        {
            text: i18n("Call")
        }

        MenuItem
        {
            text: i18n("Message")
        }

        MenuItem
        {
            text: i18n("Save")
        }

        MenuItem
        {
            text: i18n("Search Web")
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
        property bool ctrlPressed : false

        Keys.onPressed: (event) =>
                        {
                            console.log("key pressed", event.key, event.key == Qt.Key_Control )
                            if(event.key == Qt.Key_Control)
                            {
                                console.log("ctrl pressed")
                                ctrlPressed = true
                            }

                            if((event.key == Qt.Key_Right))
                            {
                                next()
                            }

                            if((event.key == Qt.Key_Left))
                            {
                                previous()
                            }


                            event.accepted = false
                        }

        Keys.onReleased:(event)=>
                        {
                            if(event.key == Qt.Key_Control)
                            {
                                console.log("ctrl released")

                                ctrlPressed = false
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
            readonly property bool preloadInfo: ListView.isCurrentItem
            //            active : ListView.isCurrentItem
            asynchronous: true

            sourceComponent: model.format === "gif" || model.format === "avif" ? _animatedImgComponent : _imgComponent

            Component
            {
                id: _animatedImgComponent
                Maui.AnimatedImageViewer
                {
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
                    image.cache: true

                    Loader
                    {
                        active: (_viewerLoaderDelegate.preloadInfo && viewerSettings.enableOCR) || item
                        parent:  _imgV.image
                        height: _imgV.image.paintedHeight
                        width:  _imgV.image.paintedWidth
                        anchors.centerIn:  parent
                        visible: active && viewerSettings.enableOCR
                        sourceComponent: Item
                        {
                            opacity: 0.5

                            Item
                            {
                                id: _boxes
                                anchors.fill: parent

                                signal resetSelection();
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
                                        property string text : modelData.text

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
                                            height: parent.height + 6
                                            width: parent.width+6
                                            anchors.centerIn: parent
                                            radius: 0
                                            color: Maui.Theme.linkBackgroundColor
                                            opacity: 0.7
                                            visible: _mouseArea.containsMouse || parent.selected
                                        }

                                        onClicked: (mouse) =>
                                                   {
                                                       if(mouse.button == Qt.RightButton)
                                                       {
                                                           selected = true
                                                           _selectionMenu.text = _selectionArea.selectedText.length > 0 ? _selectionArea.selectedText.join(" ") : modelData.text
                                                           _selectionMenu.show()
                                                       }
                                                   }

                                        // Connections
                                        // {
                                        // }

                                        ToolTip.delay: 1000
                                        ToolTip.timeout: 5000
                                        ToolTip.visible: _mouseArea.containsMouse
                                        ToolTip.text: index
                                    }
                                }
                            }

                            MouseArea
                            {
                                id: _selectionArea
                                enabled: !Maui.Handy.isMobile
                                anchors.fill: parent
                                preventStealing: false
                                cursorShape: viewerList.ctrlPressed ? Qt.IBeamCursor : undefined
                                acceptedButtons: Qt.LeftButton

                                property var pressedPosition
                                property var selectedText: []
                                property var selectedIndexes: []

                                onClicked:(mouse) => mouse.accepted= false

                                onPressed: (mouse) =>
                                           {
                                               console.log(mouse.modifiers === Qt.NoModifier)
                                               if (mouse.modifiers === Qt.NoModifier)
                                               {
                                                   _boxes.resetSelection()
                                                   selectedText = []
                                                   selectedIndexes = []
                                               }

                                               pressedPosition = Qt.point(mouse.x, mouse.y)
                                           }

                                onReleased:
                                {
                                    selectedText = []
                                    selectedIndexes.sort(function(a, b) {
                                        return a - b;
                                    })
                                    console.log("Selected indexes sorted", selectedIndexes)
                                    for(var i of selectedIndexes)
                                    {
                                        selectedText.push(_repeater.itemAt(i).text)
                                    }
                                }

                                onPositionChanged: (mouse) =>
                                                   {
                                                       if(Math.round(mouse.x)%2 === 0 || Math.round(mouse.y)%2 === 0)
                                                       {

                                                           if(_selectionArea.containsPress && mouse.modifiers === Qt.ControlModifier)
                                                           {
                                                               if(viewerSettings.ocrSelectionType === 0)
                                                               {
                                                                   console.log("Selection tool",pressedPosition, mouse.x, mouse.y)
                                                                   let point = mapPoint(Qt.point(mouse.x, mouse.y))
                                                                   let index = _ocr.wordBoxAt(point)
                                                                   let box = _repeater.itemAt(index)
                                                                   if(box)
                                                                   {
                                                                       if(selectedIndexes.indexOf(index) < 0)
                                                                       {
                                                                           box.selected = true
                                                                           selectedIndexes.push(index)
                                                                       }
                                                                   }
                                                                   console.log(index, box.text, box.selected)
                                                               }else
                                                               {
                                                                   _boxes.resetSelection()
                                                                   let point2 = mapPoint(Qt.point(mouse.x, mouse.y))
                                                                   let point1 = mapPoint(_selectionArea.pressedPosition)

                                                                   let rect = Qt.rect(point1.x, point1.y, Math.abs(point2.x-point1.x), Math.abs(point2.y-point1.y))

                                                                   selectedIndexes = _ocr.wordBoxesAt(rect)
                                                                   console.log("Selected rect:" , rect, selectedIndexes)

                                                                   for(var i of selectedIndexes)
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

    Button
    {
        Maui.Theme.inherit: false
        Maui.Theme.colorSet: Maui.Theme.Complementary
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Maui.Style.space.big

        icon.name:  "draw-text"

        checked: viewerSettings.enableOCR

        onClicked: viewerSettings.enableOCR = !viewerSettings.enableOCR

        background: Rectangle
        {
            opacity: 0.7
            color: checked ? Maui.Theme.highlightColor : Maui.Theme.backgroundColor
            radius: Maui.Style.radiusV
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
}
