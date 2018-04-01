import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../custom/TagBar"
import "../../../db/Query.js" as Q
import "../../views/Pix.js" as PIX

PixPopup
{
    padding: contentMargins*2
    parent: parent
    maxWidth: 200
    height: 120
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
        if (pix.addAlbum(albumText.text))
            albumCreated(albumText.text)
        albumText.clear()
        close()
    }
}
