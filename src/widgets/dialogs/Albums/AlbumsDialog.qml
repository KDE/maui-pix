import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../db/Query.js" as Q
import "../../views/Pix.js" as PIX
import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{
    property var picUrls : []
    signal picTagged(string tag)

    maxHeight: unit * 500

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
        }

        Maui.TextField
        {
            id: albumText
            Layout.fillWidth: true
            placeholderText: qsTr("New album...")
            onAccepted:
            {
                albumsList.model.insert(0, {album: albumText.text})
                clear()
            }
        }
    }

    function show(urls)
    {
        albumsDialog.picUrls = urls
        albumsDialog.open()
    }

    function addToAlbum(album)
    {
        var albumExists = pix.checkExistance("albums", "album", album)
        for(var i in picUrls)
        {
            if(pix.picAlbum(album, picUrls[i]) && !albumExists)
                albumsView.albumsGrid.model.append({album : album})
        }
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
