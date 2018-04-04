import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../../../view_models"

PixDialog
{
    standardButtons: Dialog.Save | Dialog.Cancel
    title: qsTr("Viewer configuration")

    GridLayout
    {
        anchors.fill: parent
        rowSpacing: contentMargins

        rows: 1
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
            Layout.fillWidth: true
            Layout.row: 1
            Layout.column: 2
            placeholderText: "#000"

            text: backgroundColor

            onAccepted:
            {
                viewerBackgroundColor = text
                pix.saveSettings("VIEWER_BG_COLOR", viewerBackgroundColor, "PIX")
            }

        }

    }
}
