import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"
import "../../../db/Query.js" as Q
import "../../views/Pix.js" as PIX

import "../../dialogs/Albums"
import "../../dialogs/Tags"


Kirigami.PageRow
{
    id: albumsPageRoot
    property alias albumsGrid : albumGrid
    separatorVisible: albumsPageRoot.wideMode
    initialPage: [albumsPage, picsView]
    defaultColumnWidth: parent.width
    interactive: albumsPageRoot.currentIndex  === 1
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

    Maui.Page
    {
        id: albumsPage
        headBar.visible: false
        floatingBar: true
        footBarOverlap: true
        allowRiseContent: false
        footBarAligment: Qt.AlignRight
        footBarMargins: space.huge

        footBar.colorScheme.backgroundColor: altColor
        footBar.colorScheme.borderColor: Qt.darker(altColor, 1.4)
        footBar.middleContent: Maui.ToolButton
        {
            iconName: "list-add"
            onClicked: newAlbumDialog.open()
            iconColor: altColorText
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
        anchors.fill: parent

        headBar.visible: true

        holder.title: "No Pics!"
        holder.body: "This album is empty"
        holder.isMask: false
        holder.emojiSize: iconSizes.huge
        holder.emoji: "qrc:/img/assets/MoonSki.png"

        headBarExit: albumsPageRoot.currentIndex === 1
        headBarExitIcon: "go-previous"
        headBarTitle: albumGrid.currentAlbum

        onExit: albumsPageRoot.currentIndex = 0

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
        albumsPageRoot.currentIndex = 1
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
