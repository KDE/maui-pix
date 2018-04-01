import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import "../../../db/Query.js" as Q
import "../../dialogs/Albums"

PixPage
{
    property alias albumsGrid : albumGrid

    headerbarExit: stackView.currentItem === picsView
    headerbarExitIcon: "go-previous"
    headerbarTitle: albumGrid.count+qsTr(" Albums")

    onExit:
    {
        stackView.pop(albumGrid)
        headerbarTitle: albumGrid.count+qsTr(" Albums")
    }

    headerBarRight: [

        PixButton
        {
            iconName: "overflow-menu"
        }

    ]

    headerBarLeft: [

        PixButton
        {
            iconName: "list-add"
            visible: stackView.currentItem === albumGrid
            onClicked: newAlbumDialog.open()
        }
    ]

    NewAlbumDialog
    {
        id: newAlbumDialog
        onAlbumCreated: albumGrid.model.append({"album": album})
    }

    content: StackView
    {
        id: stackView
        height: parent.height
        width: parent.width

        initialItem: AlbumsGrid
        {
            id: albumGrid

            onAlbumClicked: populateAlbum(model.get(index).album)
        }

        PixGrid
        {
            id: picsView
            headerbarVisible: false

        }
    }

    function populate()
    {
        var albums = pix.get(Q.Query.allAlbums)
        if(albums.length > 0)
            for(var i in albums)
                albumGrid.model.append(albums[i])

    }

    function clear()
    {
        albumGrid.model.clear()
    }

    function populateAlbum(album)
    {
        headerbarTitle = album
        picsView.clear()

        var pics = pix.get(Q.Query.albumPics_.arg(album))

        if(pics.length > 0)
            for(var i in pics)
                picsView.grid.model.append(pics[i])

        if(stackView.currentItem === albumGrid)
            stackView.push(picsView)
    }

}
