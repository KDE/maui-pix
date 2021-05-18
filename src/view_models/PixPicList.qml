// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.mauikit.controls 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ListBrowserDelegate
{
    id: control

    iconSizeHint: height * 0.9

    label1.text: model.title
    label2.text: model.url

    label3.text:  model.format
    label4.text:  Maui.Handy.formatDate(model.modified, "MM/dd/yyyy")

    imageSource: (model.url && model.url.length>0) ? model.url : "qrc:/img/assets/image-x-generic.svg"
}
