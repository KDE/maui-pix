// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ItemDelegate
{
    id: control

    property alias checkable : _template.checkable
    property alias checked : _template.checked
    property alias labelsVisible: _template.labelsVisible
    signal toggled(int index, bool state);

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered
    ToolTip.text: model.url

    draggable: true

    Maui.ListItemTemplate
    {
        id: _template
        anchors.fill: parent
        maskRadius: control.radius
        isCurrentItem: control.isCurrentItem
        iconSizeHint: height * 0.7
        imageHeight: height
        imageWidth: width

        label1.text: model.title
        label2.text: model.url

        label3.text:  model.format
        label4.text:  Maui.FM.formatDate(model.modified, "MM/dd/yyyy")

        imageSource: (model.url && model.url.length>0) ? model.url : "qrc:/img/assets/image-x-generic.svg"
        hovered: control.hovered
        checkable: control.checkable
        onToggled: control.toggled(index, state)
    }
}
