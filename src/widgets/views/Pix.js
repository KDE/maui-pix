.import "../../db/Query.js" as Q

function refreshViews()
{
    galleryView.populate()
    foldersView.populate()
    albumsView.populate()
    tagsView.populate()
}

function addTagToPic(myTag, url)
{
    return tag.tagUrl(url, myTag)
}

function addTagToAlbum(tag, url)
{
    return pix.albumTag(tag, url)
}

function removePic(urls)
{
    for(var i in urls)
    {
        var url = urls[i]

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

function searchFor(query)
{
    if(currentView !== views.search)
        currentView = views.search

    searchView.runSearch(query)
}
