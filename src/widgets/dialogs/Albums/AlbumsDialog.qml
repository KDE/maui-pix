import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../db/Query.js" as Q
import "../../views/Pix.js" as PIX

PixDialog
{

    property string picUrl : ""
    signal picTagged(string tag)

    standardButtons: Dialog.Save | Dialog.Cancel

    onOpened: populate()
    onAccepted: addToAlbum(albumsList.model.get(albumsList.currentIndex).album)


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
            Layout.leftMargin: contentMargins
            Layout.rightMargin: contentMargins
            placeholderText: "New album..."
            onAccepted:
            {
               albumsList.model.insert(0, {album: albumText.text})
                clear()
            }
        }
    }

    function show(url)
    {
        albumsDialog.picUrl = url
        albumsDialog.open()
    }

    function addToAlbum(album)
    {
        var albumExists = pix.checkExistance("albums", "album", album)
        if(pix.picAlbum(album, picUrl) && !albumExists)
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
