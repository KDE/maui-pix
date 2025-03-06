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

        Keys.onPressed: (event) =>
                        {
                            if((event.key == Qt.Key_Right))
                            {
                                next()
                            }

                            if((event.key == Qt.Key_Left))
                            {
                                previous()
                            }
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

                            Repeater
                            {
                                // model: _ocr.wordBoxes
                                model: _ocr.paragraphBoxes
                                // model: _ocr.lineBoxes

                                delegate: MouseArea
                                {
                                    id: _mouseArea
                                    hoverEnabled: !Maui.Handy.isMobile
                                    x: parent.width * modelData.rect.x / _imgV.image.implicitWidth
                                    y: parent.height * modelData.rect.y / _imgV.image.implicitHeight
                                    width: parent.width * modelData.rect.width / _imgV.image.implicitWidth
                                    height: parent.height * modelData.rect.height / _imgV.image.implicitHeight
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.RightButton
                                    Rectangle
                                    {
                                        anchors.fill: parent
                                        radius: 2
                                        color: Maui.Theme.linkBackgroundColor
                                        opacity: 0.7
                                        visible: _mouseArea.containsMouse
                                    }

                                    onClicked: (mouse) =>
                                               {
                                                   if(mouse.button == Qt.RightButton)
                                                   {
                                                       _selectionMenu.text = modelData.text
                                                       _selectionMenu.show()
                                                   }
                                               }

                                    ToolTip.delay: 1000
                                    ToolTip.timeout: 5000
                                    ToolTip.visible: _mouseArea.containsMouse
                                    ToolTip.text: modelData.text
                                }
                            }


                            IT.OCR
                            {
                                id: _ocr
                                filePath: model.url
                                autoRead: true
                                boxesType: IT.OCR.Paragraph
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
