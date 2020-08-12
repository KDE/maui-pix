// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ImageViewer
{
    property int itemWidth : parent.width
    property int itemHeight : parent.height
    readonly property string currentImageSource: model.url

    source : currentImageSource

    width: itemWidth
    height: itemHeight
    animated: model.format === "gif"
}
