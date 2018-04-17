import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import "../../../db/Query.js" as Q

import "../../dialogs/Albums"
import "../../../widgets/custom/TagBar"
import "../../dialogs/Tags"


Page
{
    property alias albumsGrid : albumGrid


    footer: ToolBar
    {
        id: footerBar
        position: ToolBar.Footer
        visible: false
        TagBar
        {
            id: tagBar
            anchors.fill: parent
            onAddClicked: tagsDialog.show(albumGrid.currentAlbum)

            onTagRemovedClicked: if(pix.removeAlbumTag(tagsList.model.get(index).tag, albumGrid.currentAlbum))
                                     tagsList.model.remove(index)
        }
    }

    TagsDialog
    {
        id: tagsDialog
        forAlbum: true
        onTagsAdded: addTagsToAlbum(url, tags)
        onAlbumTagged: tagBar.tagsList.model.insert(0, {"tag": tag})
    }

    NewAlbumDialog
    {
        id: newAlbumDialog
        onAlbumCreated: albumGrid.model.append({"album": album})
    }

    StackView
    {
        id: stackView
        height: parent.height
        width: parent.width

        initialItem: PixPage
        {
            id: albumsPage
            headerbarTitle: albumGrid.count+qsTr(" Albums")
            headerbarExit: false

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

            content: AlbumsGrid
            {
                id: albumGrid
                height: parent.height
                width: parent.width
                onAlbumClicked: filter(model.get(index).album)
            }
        }

        PixGrid
        {
            id: picsView
            headerbarVisible: true
            holder.message: "<h2>No Pics!</h2><p>This albums is empty</p>"
            holder.emoji: "qrc:/img/assets/face-sleeping.png"

            headerbarExit: stackView.currentItem === picsView
            headerbarExitIcon: "go-previous"
            headerbarTitle: albumGrid.currentAlbum

            onExit: stackView.pop(albumsPage)
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
        albumGrid.currentAlbum = album
        picsView.clear()
        tagBar.tagsList.model.clear()
        footerBar.visible = false

        switch(album)
        {
        case "Favs":
            populateAlbum(Q.Query.favPics)
            break
        case "Recent":
            populateAlbum(Q.Query.recentPics)
            break
        default:
            populateAlbum(Q.Query.allAlbumPics_.arg(album))

            footerBar.visible = true
            tagBar.tagsList.populate(Q.Query.albumTags_.arg(album))
            break
        }
    }

    function populateAlbum(query)
    {
        var pics = pix.get(query)

        if(pics.length > 0)
            for(var i in pics)
                picsView.grid.model.append(pics[i])

        if(stackView.currentItem === albumsPage)
            stackView.push(picsView)
    }

}
