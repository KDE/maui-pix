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

    property bool focusedMode : false

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
        Keys.forwardTo: currentItem
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
                                console.log("Current pic is", currentPic)
                                openEditor(currentPic.url, _stackView)
                                event.accepted = true
                                return
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

            Keys.enabled: true
            Keys.forwardTo: item

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

                    Keys.forwardTo: _ocrLoader.item

                    readonly property bool imageReady: _imgV.image.status == Image.Ready
                    onClicked: (mouse) =>
                               {
                                   control.focusedMode = !control.focusedMode
                                   mouse.accepted = false
                               }

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
                        id: _ocrLoader
                        active: (_viewerLoaderDelegate.isCurrentItem && viewerSettings.enableOCR && _timer.ready)
                        parent:  _imgV.image
                        height: _imgV.image.paintedHeight
                        width:  _imgV.image.paintedWidth
                        anchors.centerIn:  parent
                        visible: active && viewerSettings.enableOCR
                        sourceComponent: OCROverlay
                        {

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
