// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.pix as Pix

import "../../../view_models"


PixGrid
{
    id: control

    property string currentTag
    property var currentFilters : []

    holder.visible: count === 0

    holder.title: i18n("No Pics in %1!", currentTag)
    holder.body: i18n("There're no pics associated with the tag")
    holder.emoji: "qrc:/assets/add-image.svg"

    headBar.visible: true

    function refreshPics()
    {
        control.list.refresh()
    }  
}



