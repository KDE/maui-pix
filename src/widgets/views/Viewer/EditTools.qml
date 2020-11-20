// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

Maui.Drawer
{
    modal: false
    edge: Qt.RightEdge
    spacing: 0
    bg: viewer

    ColumnLayout
    {
        anchors.fill: parent
        spacing: contentMargins

        Maui.ToolBar
        {
            Layout.fillWidth: true

            width: parent.width
            position: ToolBar.Header

            middleContent: [
                ToolButton
                {
                    iconName: "object-rotate-left"
                    onClicked: viewer.list.currentItem.rotateLeft()
                }
                ,
                ToolButton
                {
                    iconName: "object-rotate-right"
                    onClicked: viewer.list.currentItem.rotateRight()
                }
            ]
        }

        ScrollView
        {
            id: scrollView
            clip: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: contentMargins

            GridLayout
            {
                width: scrollView.availableWidth
                height: scrollView.availableHeight
                rows: 11
                columns: 1
                columnSpacing: contentMargins

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 1
                    Layout.column: 1
                    width: parent.width
                    text: i18n("Color")
                    font.pointSize: Maui.Style.fontSizes.big
                    font.weight: Font.Bold
                    font.bold: true
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 2
                    Layout.column: 1

                    text: i18n("Contrast")
                }

                Slider
                {
                    id: contrastSlider
                    width: parent.width
                    Layout.fillWidth: true
                    Layout.row: 3
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picContrast = value
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 4
                    Layout.column: 1
                    width: parent.width

                    text: i18n("Brightness")
                }

                Slider
                {
                    id: brightnessSlider
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.row: 5
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picBrightness = position
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 6
                    Layout.column: 1
                    width: parent.width

                    text: i18n("Saturation")
                }

                Slider
                {
                    id: saturationSlider
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.row: 7
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picSaturation = value
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 8
                    Layout.column: 1
                    width: parent.width

                    text: i18n("Hue")
                }

                Slider
                {
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.row: 9
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picHue = value
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 10
                    Layout.column: 1
                    width: parent.width

                    text: i18n("Lightness")
                }

                Slider
                {
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.row: 11
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picLightness = value
                }

            }
        }
    }
}
