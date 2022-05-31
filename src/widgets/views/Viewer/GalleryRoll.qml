// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.14
import QtQuick.Controls 2.14

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.pix 1.0

import "../../../view_models"

ScrollView
{
    id: control
    property alias rollList : rollList
    property alias model: rollList.model

    signal picClicked(int index)

    contentHeight: availableHeight

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

    ListView
    {
        id: rollList
        currentIndex: currentPicIndex
        orientation: ListView.Horizontal
        clip: true
        spacing: 0

        boundsBehavior: Flickable.StopAtBounds
        boundsMovement :Flickable.StopAtBounds

        interactive: Kirigami.Settings.hasTransientTouchInput

        delegate: PixPic
        {
            height: ListView.view.height
            width: height * (isCurrentItem ? 2 : 1)

            isCurrentItem: ListView.isCurrentItem

            labelsVisible: false
            fit: false
            maskRadius: 0
            checkable: false

            onClicked:
            {
                rollList.currentIndex = index
                picClicked(index)
            }

            onPressAndHold: _picMenu.show()
            onRightClicked: _picMenu.show()

            Behavior on width
            {
                NumberAnimation
                {
                    duration: Maui.Style.units.longDuration
                    easing.type: Easing.InQuad
                }
            }

        }
    }

    function position(index)
    {
        rollList.currentIndex = index
        rollList.positionViewAtIndex(index, ListView.Center)
    }
}

