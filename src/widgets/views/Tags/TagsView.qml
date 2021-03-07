// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14

import org.kde.kirigami 2.14 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.pix 1.0 as Pix

import "../../../view_models"

StackView
{
    id: control
    clip: true

    property string currentTag : ""
    property Flickable flickable : currentItem.flickable

    Maui.NewTagDialog
    {
        id: newTagDialog

    }

    initialItem: TagsSidebar { }

    Component
    {
        id: tagsGrid

        PixGrid
        {
            title: control.currentTag
            list.urls : ["tags:///"+currentTag]
            list.recursive: false
            holder.title: i18n("No Pics!")
            holder.body: i18n("There's no pics associated with the tag")
            holder.emojiSize: Maui.Style.iconSizes.huge
            holder.emoji: "qrc:/img/assets/add-image.svg"
            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }
        }
    }

    function refreshPics()
    {
        tagsGrid.list.refresh()
    }

    function populateGrid(myTag)
    {
        currentTag = myTag
        control.push(tagsGrid)
    }
 }
