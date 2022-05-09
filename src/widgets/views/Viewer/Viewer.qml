// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.imagetools 1.0 as IT

import org.maui.pix 1.0

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

    property alias count : viewerList.count
    property alias currentIndex : viewerList.currentIndex
    property alias currentItem: viewerList.currentItem

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

        clip: true
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

        Keys.onPressed:
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
                    source: model.url
//                    imageWidth: 1000
//                    imageHeight: 1000
                    image.autoTransform: true
                }
            }
        }
    }

    MouseArea
    {
        enabled: viewerSettings.previewBarVisible && galleryRoll.rollList.count > 1
        anchors.fill: parent
        onPressed:
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
