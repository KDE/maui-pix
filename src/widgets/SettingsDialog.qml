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

        Maui.SettingTemplate
        {
            label1.text: i18n("Auto Scan")
            label2.text: i18n("Scan the collection sources on startup")

            Switch
            {
                checkable: true
                checked: root.autoScan
                onToggled:
                {
                    root.autoScan = !root.autoScan
                    Maui.FM.saveSettings("AUTOSCAN", root.autoScan, "SETTINGS")
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Auto Reload")
            label2.text: i18n("Watch for changes in the collection sources")

            Switch
            {
                checkable: true
                checked: root.autoScan
                onToggled:
                {
                    root.autoReload = !root.autoReload
                    Maui.FM.saveSettings("AUTORELOAD", autoReload, "SETTINGS")
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Collection")
        description: i18n("Configure the app plugins and look & feel.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Fit")
            label2.text: i18n("Fit the previews")

            Switch
            {
                //                        visible: false //TODO to fix
                icon.name: "image-preview"
                checkable: true
                checked: root.fitPreviews
                onToggled:
                {
                    root.fitPreviews = !root.fitPreviews
                    Maui.FM.saveSettings("PREVIEWS_FIT", fitPreviews, "GRID")
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Titles")
            label2.text: i18n("Show titles of the images")

            Switch
            {
                checkable: true
                checked: root.showLabels
                onToggled:
                {
                    root.showLabels = !root.showLabels
                    Maui.FM.saveSettings("SHOW_LABELS", showLabels, "GRID")
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Preview Size")
            label2.text: i18n("Size of the thumbnails in the collection navigation views")

            Maui.ToolActions
            {
                id: _gridIconSizesGroup
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
    }

    Maui.SettingsSection
    {
        title: i18n("Viewer")
        description: i18n("Adjust the viewer panels and settings")

        Maui.SettingTemplate
        {
            label1.text: i18n("Tag Bar")
            label2.text: i18n("Easy access to add, remove and modify tags to the current image")

            Switch
            {
                checkable: true
                checked: pixViewer.tagBarVisible
                onToggled: pixViewer.toogleTagbar()
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Preview Bar")
            label2.text: i18n("Show thumnail previews in the image viewer")

            Switch
            {
                checkable: true
                checked: pixViewer.roll.visible
                onToggled: pixViewer.tooglePreviewBar()
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Sources")
        description: i18n("Add new sources to manage and browse your image collection")

        ColumnLayout
        {
            Layout.fillWidth: true

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
