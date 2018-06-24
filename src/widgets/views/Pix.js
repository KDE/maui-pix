.import "../../db/Query.js" as Q

function refreshViews()
{
    galleryView.populate()
    foldersView.populate()
    albumsView.populate()
    tagsView.populate()
}

function addTagToPic(tag, url)
{
    return tag.tagUrl(tag, url)
}

function addTagToAlbum(tag, url)
{
    return pix.albumTag(tag, url)
}

function removePic(url)
{
    if(pix.removeFile(url))
    {
        switch(currentView)
        {
        case views.gallery :
            galleryView.populate()
            break
        case views.folders:
            foldersView.picsView.populate(foldersView.currentFolder)
            break
        case views.albums:
            albumsView.filter(albumsView.albumsGrid.currentAlbum)
            break
        case views.tags:
            tagsView.populateGrid(tagsView.currentTag)
            break
        case views.search:
            searchView.runSearch(searchView.currentQuery)

        }
    }
}

function addTagsToPic(tags, url)
{
    for(var i in tags)
        addTagToPic(tags[i], url)
}

function updatePicTags(tags, url)
{
    tag.updateUrlTags(url, tags)
}
