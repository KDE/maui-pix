// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.pix 1.0 as Pix

import "../../../view_models"

StackView
{
    id: control
    clip: true

    property string currentTag : ""
    property Flickable flickable : currentItem.flickable

    Maui.NewDialog
    {
        id: newTagDialog
        title: i18n("New tag")
        message: i18n("Create a new tag to organize your gallery")
        acceptButton.text : i18n("Add")
        onFinished:
        {
            tagsList.insert(text)
        }

        onRejected: close()
    }

    initialItem: TagsSidebar
    {
        id: tagsSidebar
    }

    Component
    {
        id: tagsGrid
        PixGrid
        {
            title: control.currentTag
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
        control.push(tagsGrid)
        control.currentItem.list.clear()

        const urls = Pix.Collection.getTagUrls(myTag, true);
        console.log(urls)
        if(urls.length > 0)
            for(const i in urls)
            {
                if(Maui.FM.checkFileType(Maui.FMList.IMAGE, urls[i].mime))
                    control.currentItem.list.append(urls[i].url)
            }

    }
 }
