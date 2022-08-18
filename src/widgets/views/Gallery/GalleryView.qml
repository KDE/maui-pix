// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.10

import QtQuick.Controls 2.10
import QtQuick.Layouts 1.12

import org.maui.pix 1.0 as Pix
import org.mauikit.controls 1.3 as Maui
import org.maui.pix 1.0

import "../../../view_models"

PixGrid
{
    id: control
    holder.emoji: "qrc:/assets/image-multiple.svg"
    holder.title : i18n("No Pics!")
    holder.body: mainGalleryList.status === GalleryList.Error ? mainGalleryList.error : i18n("Nothing here. You can add new sources or open an image.")
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
