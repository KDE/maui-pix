import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.imagetools as IT

Maui.SettingsPage
{
    id: control

    title: i18n("Text Detection")


    Pane
    {
        Layout.fillWidth: true
        implicitHeight: implicitContentHeight + topPadding + bottomPadding

        background: Rectangle
        {
            anchors.fill: parent
            color: "#333"
            radius: Maui.Style.radiusV
            Image
            {
                anchors.fill: parent
                source:  "://assets/paper_texture.png"
                // opacity: 0.5
            }
        }

        contentItem: ColumnLayout
        {
            Label
            {
                text: "Lorem."
                color: "white"
                font: Maui.Style.h1Font
                background: Rectangle
                {
                    color: Maui.Theme.highlightColor
                    radius: 4
                    visible: viewerSettings.ocrBlockType === 0
                }
            }

            Label
            {
                text: "Praesent aliquet congue nibh, volutpat bibendum leo."
                color: "white"
                horizontalAlignment: Qt.AlignHCenter
                background: Rectangle
                {
                    color: Maui.Theme.highlightColor
                    radius: 4
                    visible: viewerSettings.ocrBlockType === 1
                }
            }

            Label
            {
                Layout.fillWidth: true
                text: "Mauris sodales mauris at felis finibus placerat non quis tortor. Nulla pulvinar vestibulum dapibus. Morbi dictum est nibh. Curabitur ac ante vehicula, fringilla velit ac, auctor ipsum. Phasellus nec sollicitudin libero. Vestibulum quis augue dignissim, rhoncus urna id, fringilla dolor. Donec id est condimentum, posuere nisl vitae, iaculis libero."
                color: "white"
                font: Maui.Style.monospacedFont
                wrapMode: Text.Wrap
                opacity: 0.6
                background: Rectangle
                {
                    color: Maui.Theme.highlightColor
                    radius: 4
                    visible: viewerSettings.ocrBlockType === 2
                }
            }
        }
    }



    Maui.FlexSectionItem
    {
        label1.text: i18n("Enable Auto Detection")

        Switch
        {
            checked: viewerSettings.enableOCR
            onToggled: viewerSettings.enableOCR = !viewerSettings.enableOCR
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Image Preprocessing")
        label2.text: i18n("Enable image preprocessing.")
        Switch
        {
            checked: viewerSettings.ocrPreprocessing
            onToggled: viewerSettings.ocrPreprocessing = !viewerSettings.ocrPreprocessing
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Page Segmentation")
        ComboBox
        {
            editable: false
            textRole: "text"
            valueRole: "value"
            // When an item is selected, update the backend.
            onActivated: viewerSettings.ocrSegMode = currentValue
            // Set the initial currentIndex to the value stored in the backend.
            Component.onCompleted: currentIndex = indexOfValue(viewerSettings.ocrSegMode)
            model: [
                { value: IT.OCR.Auto, text: i18n("Auto") },
                { value: IT.OCR.Auto_OSD, text: i18n("Auto OSD") },
                { value: IT.OCR.SingleColumn, text: i18n("Single Column") },
                { value: IT.OCR.SingleLine, text: i18n("Single Line") },
                { value: IT.OCR.SingleBlock, text: i18n("Single Block") },
                { value: IT.OCR.SingleWord, text: i18n("Single Word") }
            ]
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Confidence Threshold")

        SpinBox
        {
            from: 1
            to: 100
            value: viewerSettings.ocrConfidenceThreshold
            onValueModified:
            {
                viewerSettings.ocrConfidenceThreshold = value
            }
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Text Block Detection")

        Maui.ToolActions
        {
            autoExclusive: true

            Action
            {
                text: i18n("Word")
                checked: viewerSettings.ocrBlockType === 0
                onTriggered: viewerSettings.ocrBlockType = 0
            }

            Action
            {
                text: i18n("Line")
                checked: viewerSettings.ocrBlockType === 1
                onTriggered: viewerSettings.ocrBlockType = 1
            }

            Action
            {
                text: i18n("Paragraph")
                checked: viewerSettings.ocrBlockType === 2
                onTriggered: viewerSettings.ocrBlockType = 2
            }
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Text Block Selection")
        label2.text: i18n("For selecting multiple blocks in the free mode, hold down the Shift key while moving around.")

        Maui.ToolActions
        {
            autoExclusive: true

            Action
            {
                text: i18n("Free")
                checked: viewerSettings.ocrSelectionType === 0
                onTriggered: viewerSettings.ocrSelectionType = 0
            }

            Action
            {
                text: i18n("Rectangular")
                checked: viewerSettings.ocrSelectionType === 1
                onTriggered: viewerSettings.ocrSelectionType = 1
            }
        }
    }
}
