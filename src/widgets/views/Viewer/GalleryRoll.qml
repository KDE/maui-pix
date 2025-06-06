// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui

import org.maui.pix 1.0

import "../../../view_models"

ScrollView
{
    id: control

    readonly property alias rollList : rollList
    property alias model: rollList.model
    property alias currentIndex : rollList.currentIndex

    onCurrentIndexChanged: position(currentIndex)

    signal picClicked(int index)

    contentHeight: availableHeight

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

    Maui.Controls.orientation: Qt.Horizontal

    ListView
    {
        id: rollList
        orientation: ListView.Horizontal
        clip: true
        spacing: 0

        boundsBehavior: Flickable.StopAtBounds
        boundsMovement :Flickable.StopAtBounds

        interactive: Maui.Handy.hasTransientTouchInput

        delegate: PixPic
        {
            height: ListView.view.height
            width: height

            imageWidth: height
            imageHeight: height

            isCurrentItem: ListView.isCurrentItem

            labelsVisible: false
            fit: false
            maskRadius: 0
            checkable: false

            onClicked:
            {
                picClicked(index)
            }
        }
    }

    function position(index)
    {
        // rollList.setCurrentIndex(index)
        rollList.positionViewAtIndex(index, ListView.Center)
    }
}

