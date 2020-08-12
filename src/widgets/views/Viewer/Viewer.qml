// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.13
import QtQuick.Controls 2.13
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import GalleryList 1.0

import "../../"
import "Viewer.js" as VIEWER

Item
{
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
        currentIndex: currentPicIndex
        clip: true
        focus: true
        interactive: Maui.Handy.isTouch
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        highlightResizeDuration : 0
        snapMode: ListView.SnapOneItem
        cacheBuffer: width * 3

        keyNavigationEnabled : true
        keyNavigationWraps : true
        Keys.onPressed:
        {
            if((event.key == Qt.Key_Right))
            {
                viewerList.incrementCurrentIndex()
                VIEWER.view(currentIndex)
            }

            if((event.key == Qt.Key_Left))
            {
                viewerList.decrementCurrentIndex()
                VIEWER.view(currentIndex)
            }
        }

        onCurrentIndexChanged:viewerList.forceActiveFocus()

        onMovementEnded:
        {
            const index = indexAt(contentX, contentY)
            if(index !== currentPicIndex)
                VIEWER.view(index)
        }

        delegate: Loader
        {
            height: viewerList.height
            width: viewerList.width

            active: ListView.isCurrentItem || index === 1-viewerList.currentIndex ||  index === 1+viewerList.currentIndex

            sourceComponent: ViewerDelegate
            {
                id: delegate

                Connections
                {
                    target: delegate

                    onPressAndHold: _picMenu.popup()
                    onRightClicked: _picMenu.popup()
                }
            }
        }
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
