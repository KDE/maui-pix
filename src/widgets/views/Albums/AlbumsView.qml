import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui

import "../../../view_models"
import "../../../db/Query.js" as Q

import "../../dialogs/Albums"
import "../../../widgets/custom/TagBar"
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
        onTagsAdded: addTagsToAlbum(url, tags)
        onAlbumTagged: tagBar.tagsList.model.insert(0, {"tag": tag})
    }

    NewAlbumDialog
    {
        id: newAlbumDialog
        onAlbumCreated: albumGrid.model.append({"album": album})
    }

    Maui.Page
    {
        id: albumsPage
        anchors.fill: parent
        headBarTitle: albumGrid.count+qsTr(" Albums")
        headBarExit: false

        headBar.rightContent:  Maui.ToolButton
        {
            iconName: "overflow-menu"
        }

        headBar.leftContent: Maui.ToolButton
        {
            iconName: "list-add"
            onClicked: newAlbumDialog.open()
        }

        contentData: AlbumsGrid
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
        anchors.fill: parent

        headBarVisible: true
        holder.message: "<h2>No Pics!</h2><p>This albums is empty</p>"
        holder.emoji: "qrc:/img/assets/face-sleeping.png"

        headBarExit: albumsPageRoot.currentIndex === 1
        headBarExitIcon: "go-previous"
        headBarTitle: albumGrid.currentAlbum

        onExit: albumsPageRoot.currentIndex = 0

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

    }

    function populate()
    {
        var albums = [{album: "Favs"}, {album: "Recent"}]
        albums.push(pix.get(Q.Query.allAlbums))

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
        albumsPageRoot.currentIndex = 1
        var pics = pix.get(query)

        if(pics.length > 0)
            for(var i in pics)
                picsView.grid.model.append(pics[i])

    }

}
