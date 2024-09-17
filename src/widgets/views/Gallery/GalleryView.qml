// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.maui.pix as Pix

import "../../../view_models"

PixGrid
{
    id: control
    holder.emoji: "qrc:/assets/image-multiple.svg"
    holder.title : i18n("No Pics!")
    holder.body: mainGalleryList.status === Pix.GalleryList.Error ? mainGalleryList.error : i18n("Nothing here. You can add new sources or open an image.")
    holder.actions:[
        Action
        {
            text: i18n("Open")
            onTriggered: openFileDialog()
        },

        Action
        {
            text: i18n("Add sources")
            onTriggered: openSettingsDialog()
        }
    ]
}
