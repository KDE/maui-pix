// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick.Controls 2.10
import QtQuick 2.10
import QtQuick.Layouts 1.3
import org.maui.pix 1.0 as Pix
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

PixGrid
{
    id: galleryViewRoot
    list.urls: Pix.Collection.sources
    list.recursive: true
    holder.emoji: "qrc:/assets/image-multiple.svg"
    holder.title : i18n("No Pics!")
    holder.body: i18n("Add new sources to browse your image collection ")
    holder.emojiSize: Maui.Style.iconSizes.huge
}
