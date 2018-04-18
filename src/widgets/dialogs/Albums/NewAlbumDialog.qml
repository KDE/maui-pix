import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami

import "../../../view_models"
import "../../custom/TagBar"
import "../../../db/Query.js" as Q
import "../../views/Pix.js" as PIX

PixPopup
{
    padding: contentMargins
    parent: parent
    maxWidth: Kirigami.Units.gridUnit*8
    height: Kirigami.Units.gridUnit*6
    signal albumCreated(string album)

    ColumnLayout
    {
        anchors.fill: parent

        TextField
        {
            id: albumText
            Layout.fillWidth: true

            placeholderText: qsTr("New album...")
            onAccepted: addAlbum()
        }

        Button
        {
            text: qsTr("Create")
            Layout.alignment: Qt.AlignRight
            onClicked: addAlbum()
        }
    }

    function addAlbum()
    {
        if(!pix.checkExistance("albums", "album", albumText.text))
            if (pix.addAlbum(albumText.text))
                albumCreated(albumText.text)

        albumText.clear()
        close()
    }
}
