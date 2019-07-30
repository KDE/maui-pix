import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"
import "../../../db/Query.js" as Q
import "../../views/Pix.js" as PIX

import "../../dialogs/Albums"
import "../../dialogs/Tags"


StackView
{
    id: stackView
    property alias albumsGrid : albumGrid
    clip: true

    TagsDialog
    {
        id: tagsDialog
        forAlbum: true
        onTagsAdded: addTagsToAlbum(albumGrid.currentAlbum, tags)
    }

    Maui.NewDialog
    {
        id: newAlbumDialog
        title: qsTr("New album")
        message: qsTr("Create a new album to organize your images. You can sync tags with different albums.")
        onFinished: addAlbum(text)
    }

   initialItem: Maui.Page
    {
        id: albumsPage
        headBar.visible: false


//        footBar.colorScheme.backgroundColor: altColor
//        footBar.colorScheme.borderColor: Qt.darker(altColor, 1.4)
        footBar.middleContent: ToolButton
        {
            icon.name: "list-add"
            onClicked: newAlbumDialog.open()
            icon.color: altColorText
        }

        AlbumsGrid
        {
            id: albumGrid
            anchors.fill: parent
            onAlbumClicked: filter(albumsList.get(index).album)
        }
    }

    PixGrid
    {
        id: picsView
        headBar.visible: true

        holder.title: "No Pics!"
        holder.body: "This album is empty"
        holder.isMask: false
        holder.emojiSize: iconSizes.huge
        holder.emoji: "qrc:/img/assets/MoonSki.png"

//        headBarExit: true
//        headBarExitIcon: "go-previous"
        title: albumGrid.currentAlbum

//        onExit: stackView.pop()

        footer: Maui.TagsBar
        {
            id: tagBar
            list.abstract: true
            list.key: "album"
            width: picsView.width
            allowEditMode: true
            onAddClicked: tagsDialog.show(albumGrid.currentAlbum)
            onTagsEdited: list.updateToAbstract(tags)
            onTagRemovedClicked: list.removeFromAbstract(index)
        }
    }

    //    function populate()
    //    {
    //        var albums = [{album: "Favs"}, {album: "Recent"}]
    //        albums.push(pix.get(Q.Query.allAlbums))

    //        if(albums.length > 0)
    //            for(var i in albums)
    //                albumGrid.model.append(albums[i])

    //    }

    function refreshPics()
    {
        picsView.list.refresh()
    }

    function filter(album)
    {
        albumGrid.currentAlbum = album
        tagBar.visible = false

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

            tagBar.visible = true
            tagBar.list.lot = album

            for(var i = 0; i < tagBar.count; i++)
            {
                var _tag = tagBar.list.get(i).tag
                var urls = tag.getUrls(_tag)
                for(var j in urls)
                    picsView.list.append(urls[j].url)
            }

            break
        }
    }

    function populateAlbum(query)
    {
        stackView.push(picsView)
        picsView.list.query = query

    }

    function addAlbum(album)
    {
        if(album.length > 0)
            albumsList.insert({"album": album})
    }

    function addTagsToAlbum(album, tags)
    {
        if(tags.length > 0)
            for(var i in tags)
                if(PIX.addTagToAlbum(tags[i], album))
                    tagBar.list.append(tags[i])

    }
}
