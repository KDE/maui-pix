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
    property alias model : viewerList.model

    readonly property alias count : viewerList.count
    readonly property alias currentIndex : viewerList.currentIndex
    readonly property alias currentItem: viewerList.currentItem

    clip: false
    focus: true

    function forceActiveFocus()
    {
        viewerList.forceActiveFocus()
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
            height: ListView.view.height
            width: ListView.view.width
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
                }
            }
        }
    }

    MouseArea
    {
        enabled: viewerSettings.previewBarVisible && galleryRoll.rollList.count > 1
        anchors.fill: parent
        onPressed: (mouse) =>
        {
            galleryRollBg.visible = !galleryRollBg.visible
            mouse.accepted = false
        }
        propagateComposedEvents: true
        preventStealing: false
    }

    Maui.BaseModel
    {
        id: _defaultModel
        list: GalleryList {}
    }

    function appendPics(pics)
    {
        model = _defaultModel

        if(pics.length > 0)
            for(var i in pics)
                _defaultModel.list.append(pics[i])

    }
}
