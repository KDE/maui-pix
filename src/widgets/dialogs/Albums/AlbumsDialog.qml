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

    property string picUrl : ""

    onOpened: populate()

    signal picTagged(string tag)

    ColumnLayout
    {
        anchors.fill: parent

        AlbumsList
        {
            id: albumsList
            Layout.fillHeight: true
            Layout.fillWidth: true
            width: parent.width
            height: parent.height
        }

        TextField
        {
            id: albumText
            Layout.fillWidth: true

            placeholderText: "New album..."
            onAccepted:
            {
               albumsList.model.insert(0, {album: albumText.text})
                clear()
            }
        }

        Button
        {
            text: qsTr("Add")
            Layout.alignment: Qt.AlignRight
            onClicked: addToAlbum(albumsList.model.get(albumsList.currentIndex).album)
        }
    }

    function addToAlbum(album)
    {
        if(pix.picAlbum(album, picUrl))
            albumsView.albumsGrid.model.append({album : album})
        close()
    }

    function populate()
    {
        albumsList.model.clear()
        var albums = pix.get(Q.Query.allAlbums)

        if(albums.length > 0)
            for(var i in albums)
                albumsList.model.append(albums[i])
    }
}
