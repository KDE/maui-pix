// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.9
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control
    padding:0
    title: i18n("Tags")
    flickable: _tagsList.flickable

    Maui.FloatingButton
    {
        id: _overlayButton
        z: 999
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Maui.Style.toolBarHeight
        anchors.bottomMargin: Maui.Style.toolBarHeight
        icon.name : "list-add"
        onClicked: newTagDialog.open()
    }

    Maui.Holder
    {
        visible: _tagsList.count === 0
        emoji: i18n("qrc:/assets/add-image.svg")
        isMask: false
        title :i18n("No Tags!")
        body: i18n("You can create new tags to organize your gallery")
        emojiSize: Maui.Style.iconSizes.huge
        z: 999
        onActionTriggered: newTagDialog.open()
    }

    Maui.GridView
    {
        id: _tagsList
        anchors.fill: parent
        model: tagsModel
        itemSize: 100
        adaptContent: true

        delegate: Maui.ItemDelegate
        {
            id: delegate
            isCurrentItem:  GridView.isCurrentItem
            height: _tagsList.cellHeight
            width: _tagsList.cellWidth
            padding: Maui.Style.space.medium
            background: Item {}

            Maui.GridItemTemplate
            {
                hovered: delegate.hovered
                isCurrentItem: delegate.isCurrentItem
                anchors.fill: parent
                label1.text: model.tag
                iconSource: model.icon
            }

            Connections
            {
                target: delegate
                onClicked:
                {
                    _tagsList.currentIndex = index
                    if(Maui.Handy.singleClick)
                    {
                        currentTag = tagsList.get(index).tag
                        populateGrid(currentTag)
                    }
                }

                onDoubleClicked:
                {
                    _tagsList.currentIndex = index
                    if(!Maui.Handy.singleClick)
                    {
                        currentTag = tagsList.get(index).tag
                        populateGrid(currentTag)
                    }
                }
            }
        }
    }
}


