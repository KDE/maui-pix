import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import "../../../db/Query.js" as Q
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER

import "../../dialogs/Albums"

PixPage
{
    property alias albumsGrid : albumGrid

    headerbarExit: stackView.currentItem === picsView
    headerbarExitIcon: "go-previous"
    headerbarTitle: stackView.currentItem === picsView ? "undefined" : albumGrid.count+qsTr(" Albums")

    onExit:
    {
        stackView.pop(albumGrid)
        headerbarTitle = "Albums"
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

            onAlbumClicked: filter(model.get(index).album)
        }

        PixGrid
        {
            id: picsView
            headerbarVisible: false
            onPicClicked: openPic(index)

            holder.message: "<h2>No Pics!</h2><p>This albums is empty</p>"
            holder.emoji: "qrc:/img/assets/face-sleeping.png"

            function openPic(index)
            {
                var data = []
                for(var i = 0; i < grid.model.count; i++)
                    data.push(grid.model.get(i))

                VIEWER.open(data, index)
            }

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

    function filter(album)
    {
        headerbarTitle = album
        picsView.clear()

        switch(album)
        {
        case "Favs":
            populateAlbum(Q.Query.favPics)
            break
        case "Recent":
            populateAlbum(Q.Query.recentPics)
            break
        default:
            populateAlbum(Q.Query.albumPics_.arg(album))
            break

        }
    }

    function populateAlbum(query)
    {
        var pics = pix.get(query)

        if(pics.length > 0)
            for(var i in pics)
                picsView.grid.model.append(pics[i])

        if(stackView.currentItem === albumGrid)
            stackView.push(picsView)
    }

}
