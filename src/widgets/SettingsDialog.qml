import QtQuick
import QtQuick.Controls
import QtQml
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.maui.pix as Pix

Maui.SettingsDialog
{
    id: control

    Maui.SectionGroup
    {
        title: i18n("Behavior")
//        description: i18n("Configure the app behaviour.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Auto Reload")
            label2.text: i18n("Watch for changes in the collection sources.")

            Switch
            {
                checkable: true
                checked: browserSettings.autoReload
                onToggled: browserSettings.autoReload = !browserSettings.autoReload
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Collection")
//        description: i18n("Configure the app plugins and look & feel.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Fit")
            label2.text: i18n("Fit the previews and preserve the aspect ratio.")

            Switch
            {
                checkable: true
                checked: browserSettings.fitPreviews
                onToggled: browserSettings.fitPreviews = !browserSettings.fitPreviews
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Image Titles")
            label2.text: i18n("Show the file name of the images.")

            Switch
            {
                checkable: true
                checked: browserSettings.showLabels
                onToggled: browserSettings.showLabels = !browserSettings.showLabels
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Preview Size")
            label2.text: i18n("Size of the thumbnails in the collection views.")

            Maui.ToolActions
            {
                id: _gridIconSizesGroup
                expanded: true
                autoExclusive: true
                display: ToolButton.TextOnly

                Action
                {
                    text: i18n("S")
                    onTriggered: setPreviewSize(previewSizes.small)
                    checked: previewSizes.small === browserSettings.previewSize
                }

                Action
                {
                    text: i18n("M")
                    onTriggered: setPreviewSize(previewSizes.medium)
                    checked: previewSizes.medium === browserSettings.previewSize

                }

                Action
                {
                    text: i18n("X")
                    onTriggered: setPreviewSize(previewSizes.large)
                    checked: previewSizes.large === browserSettings.previewSize

                }

                Action
                {
                    text: i18n("XL")
                    onTriggered: setPreviewSize(previewSizes.extralarge)
                    checked: previewSizes.extralarge === browserSettings.previewSize

                }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Sort by")
            label2.text: i18n("Change the sorting key.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.TextOnly

                Action
                {
                    text: i18n("Title")
                    onTriggered: browserSettings.sortBy = "title"
                    checked: browserSettings.sortBy === "title"
                }

                Action
                {
                    text: i18n("Modified")
                    onTriggered: browserSettings.sortBy = "modified"
                    checked: browserSettings.sortBy === "modified"

                }

                Action
                {
                    text: i18n("Size")
                    onTriggered: browserSettings.sortBy = "size"
                    checked: browserSettings.sortBy === "size"

                }

                Action
                {
                    text: i18n("Date")
                    onTriggered: browserSettings.sortBy = "date"
                    checked: browserSettings.sortBy === "date"

                }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Sort Order")
            label2.text: i18n("Change the sorting order.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.IconOnly


                Action
                {
                    text: i18n("Ascending")
                    icon.name: "view-sort-ascending"
                    onTriggered: browserSettings.sortOrder = Qt.AscendingOrder
                    checked: browserSettings.sortOrder === Qt.AscendingOrder
                }

                Action
                {
                    text: i18n("Descending")
                    icon.name: "view-sort-descending"
                    onTriggered: browserSettings.sortOrder = Qt.DescendingOrder
                    checked: browserSettings.sortOrder === Qt.DescendingOrder
                }
            }
        }


        Maui.FlexSectionItem
        {
            label1.text: i18n("GPS Tags")
            label2.text: i18n("Show GPS tags.")

            Switch
            {
                checkable: true
                checked: browserSettings.gpsTags
                onToggled: browserSettings.gpsTags = !browserSettings.gpsTags
            }

            Maui.Chip
            {
                text: i18n("Experimental feature.")

            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Viewer")
//        description: i18n("Adjust the viewer panels and settings.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Tag Bar")
            label2.text: i18n("Easy way to add, remove and modify the tags of the current image.")

            Switch
            {
                checkable: true
                checked: viewerSettings.tagBarVisible
                onToggled: toogleTagbar()
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Preview Bar")
//            label2.text: i18n("Show small thumbnail previews in the image viewer.")
            Switch
            {
                checkable: true
                checked: viewerSettings.previewBarVisible
                onToggled: tooglePreviewBar()
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Text Detection")
            label2.text: i18n("Configure settings for text detection in images.")
            enabled: viewerSettings.enableOCR

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_ocrPageComponent)
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Sources")
//        description: i18n("Add new sources to manage and browse your image collection.")

        ColumnLayout
        {
            Layout.fillWidth: true
            spacing: Maui.Style.space.medium

            Repeater
            {
                id: _sourcesList

                model: Pix.Collection.sourcesModel


                delegate: Maui.ListDelegate
                {
                    Layout.fillWidth: true

                    template.iconSource: modelData.icon
                    template.iconSizeHint: Maui.Style.iconSizes.small
                    template.label1.text: modelData.label
                    template.label2.text: modelData.path

                    template.content: ToolButton
                    {
                        icon.name: "edit-clear"
                        flat: true
                        onClicked:
                        {
                            Pix.Collection.removeSources(modelData.path)
                        }
                    }
                }
            }

            Button
            {
                Layout.fillWidth: true
                text: i18n("Add")
                onClicked:
                {
                    dialogLoader.sourceComponent = null
                    dialogLoader.sourceComponent = fmDialogComponent
                    dialog.browser.settings.onlyDirs = true
                    dialog.callback = function(urls)
                    {
                        Pix.Collection.addSources(urls)
                    }
                    dialog.open()
                }
            }
        }
    }

    Component
    {
        id: _ocrPageComponent
        OCRSettingsPage {}
    }
}
