import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.pix 1.0 as Pix

Maui.SettingsDialog
{
    Maui.SettingsSection
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
    Maui.SettingsSection
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

            Binding on currentIndex
            {
                value:  switch(root.previewSize)
                        {
                        case previewSizes.small: return 0;
                        case previewSizes.medium: return 1;
                        case previewSizes.large: return 2;
                        case previewSizes.extralarge: return 3;
                        default: return -1;
                        }
                restoreMode: Binding.RestoreValue
            }

            Action
            {
                text: i18n("S")
                onTriggered: setPreviewSize(previewSizes.small)
            }

            Action
            {
                text: i18n("M")
                onTriggered: setPreviewSize(previewSizes.medium)
            }

            Action
            {
                text: i18n("X")
                onTriggered: setPreviewSize(previewSizes.large)
            }

            Action
            {
                text: i18n("XL")
                onTriggered: setPreviewSize(previewSizes.extralarge)
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Viewer")
        description: i18n("Adjust the viewer panels and settings")

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

    Maui.SettingsSection
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
                model: Pix.Collection.sourcesModel
                delegate: Maui.ListDelegate
                {
                    width: parent.width
                    implicitHeight: Maui.Style.rowHeight * 1.2
                    leftPadding: 0
                    rightPadding: 0
                    template.iconSource: modelData.icon
                    template.iconSizeHint: Maui.Style.iconSizes.small
                    template.label1.text: modelData.label
                    template.label2.text: modelData.path
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
