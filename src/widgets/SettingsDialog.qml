// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.pix 1.0 as Pix

MauiLab.SettingsDialog
{
    MauiLab.SettingsSection
    {
        title: i18n("Behavior")
        description: i18n("Configure the app behaviour.")

        Switch
        {
            checkable: true
            checked: root.autoScan
            Kirigami.FormData.label: i18n("Auto Scan on startup")
            onToggled:
            {
                root.autoScan = !root.autoScan
                Maui.FM.saveSettings("AUTOSCAN", fitPreviews, "SETTINGS")
            }
        }

        Switch
        {
            checkable: true
            checked: root.autoScan
            Kirigami.FormData.label: i18n("Auto reaload on changes")
            onToggled:
            {
                root.autoReload = !root.autoReload
                Maui.FM.saveSettings("AUTORELOAD", autoReload, "SETTINGS")
            }
        }

    }
    MauiLab.SettingsSection
    {
        title: i18n("Collection")
        description: i18n("Configure the app plugins and look & feel.")

        Switch
        {
            //                        visible: false //TODO to fix
            icon.name: "image-preview"
            checkable: true
            checked: root.fitPreviews
            Kirigami.FormData.label: i18n("Fit previews")
            onToggled:
            {
                root.fitPreviews = !root.fitPreviews
                Maui.FM.saveSettings("PREVIEWS_FIT", fitPreviews, "GRID")
            }
        }

        Switch
        {
            Kirigami.FormData.label: i18n("Show labels")
            checkable: true
            checked: root.showLabels
            onToggled:
            {
                root.showLabels = !root.showLabels
                Maui.FM.saveSettings("SHOW_LABELS", showLabels, "GRID")
            }
        }

        Maui.ToolActions
        {
            id: _gridIconSizesGroup
            Kirigami.FormData.label: i18n("Preview Size")
            Layout.fillWidth: true
            expanded: true
            autoExclusive: true
            display: ToolButton.TextOnly

            Action
            {
                text: i18n("S")
                onTriggered: setPreviewSize(Maui.Style.iconSizes.huge * 1.2)
            }

            Action
            {
                text: i18n("M")
                onTriggered: setPreviewSize(Maui.Style.iconSizes.huge * 1.5)
            }

            Action
            {
                text: i18n("X")
                onTriggered: setPreviewSize(Maui.Style.iconSizes.huge * 1.8 )
            }

            Action
            {
                text: i18n("XL")
                onTriggered: setPreviewSize(Maui.Style.iconSizes.enormous * 1.2)
            }
        }
    }

    MauiLab.SettingsSection
    {
        title: i18n("Viewer")

        Switch
        {
            Kirigami.FormData.label: i18n("Show tag bar")
            checkable: true
            checked: pixViewer.tagBarVisible
            onToggled: pixViewer.toogleTagbar()
        }

        Switch
        {
            Kirigami.FormData.label: i18n("Show preview bar")
            checkable: true
            checked: pixViewer.roll.visible
            onToggled: pixViewer.tooglePreviewBar()
        }
    }

    MauiLab.SettingsSection
    {
        title: i18n("Sources")
        description: i18n("Add new sources to manage and browse your image collection")

        ColumnLayout
        {
            anchors.fill: parent

            Maui.ListBrowser
            {
                id: _sourcesList
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: Math.min(500, contentHeight)
                model: Pix.Collection.sources
                delegate: Maui.ListDelegate
                {
                    width: parent.width
                    iconName: "folder"
                    iconSize: Maui.Style.iconSizes.small
                    label: modelData
                    onClicked: _sourcesList.currentIndex = index
                }
            }

            RowLayout
            {
                Layout.fillWidth: true
                Button
                {
                    Layout.fillWidth: true
                    text: i18n("Remove")
                    onClicked:
                    {
                        Pix.Collection.removeSources(_sourcesList.model[_sourcesList.currentIndex])
                    }
                }

                Button
                {
                    Layout.fillWidth: true
                    text: i18n("Add")
                    onClicked:
                    {
                        dialogLoader.sourceComponent= fmDialogComponent
                        dialog.mode = dialog.modes.OPEN
                        dialog.settings.onlyDirs= true
                        dialog.show(function(paths)
                        {
                            console.log("ADD THIS PATHS", paths)
                            Pix.Collection.addSources(paths)
                        });
                    }
                }
            }
        }
    }
}
