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
    onAccepted: addToAlbum(albumsList.get(_albumsList.currentIndex).album)

    page.padding: space.medium
    ColumnLayout
    {
        anchors.fill: parent

        AlbumsList
        {
            id: _albumsList
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
                console.log("CREATING ALBUM", albumText.text)
                albumsView.addAlbum(albumText.text)
                _albumsList.currentIndex = _albumsList.count-1
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
        for(var i in picUrls)
            albumsList.insertPic(album, picUrls[i])

        close()
    }
}
