import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

Maui.Dialog
{
    title: qsTr("Viewer configuration")

    onAccepted: saveConfs()

    GridLayout
    {
        width: parent.width*0.9
        anchors.centerIn: parent
        rowSpacing: contentMargins
        rows: 3
        columns: 2

        Label
        {
            Layout.fillWidth: true
            Layout.row: 1
            Layout.column: 1

            text: qsTr("Background color")
        }

        TextField
        {
            id: bgColor
            Layout.fillWidth: true
            Layout.row: 1
            Layout.column: 2
            placeholderText: "#000"

            text: viewerBackgroundColor

            onAccepted:
            {
                viewerBackgroundColor = text
                pix.saveSettings("VIEWER_BG_COLOR", viewerBackgroundColor, "PIX")
            }
        }

        Label
        {
            Layout.fillWidth: true
            Layout.row: 2
            Layout.column: 1

            text: qsTr("Foreground color")
        }

        TextField
        {
            id: fgColor
            Layout.fillWidth: true
            Layout.row: 2
            Layout.column: 2
            placeholderText: "#000"

            text: viewerForegroundColor

            onAccepted:
            {
                viewerForegroundColor = text
                pix.saveSettings("VIEWER_FG_COLOR", viewerForegroundColor, "PIX")
            }
        }
    }

    function saveConfs()
    {
        pix.saveSettings("VIEWER_BG_COLOR", bgColor.text, "PIX")
        pix.saveSettings("VIEWER_FG_COLOR", fgColor.text, "PIX")
        viewerForegroundColor = fgColor.text
        viewerBackgroundColor = bgColor.text

    }
}
