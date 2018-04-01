import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import "../../../db/Query.js" as Q
import "../../dialogs/Albums"

PixPage
{
    headerbarExit: stackView.currentItem === picsView
    headerbarExitIcon: "go-previous"
    headerbarTitle: albumGrid.count+qsTr(" Albums")

    onExit: stackView.pop(albumGrid)

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

            onAlbumClicked:
            {
                headerbarTitle = model.get(index).album
                picsView.clear()
                //                picsView.populate(model.get(index).url)
                //                if(stackView.currentItem === folderGrid)
                //                    stackView.push(picsView)
            }
        }

        PixGrid
        {
            id: picsView
            headerbarVisible: false

        }
    }

    function populate()
    {
        var albums = pix.get(Q.Query.allAlbums())
        if(albums.length > 0)
            for(var i in albums)
                albumGrid.model.append(albums[i])

    }

    function clear()
    {
        albumGrid.model.clear()
    }

    function addAlbum()
    {

    }

}
