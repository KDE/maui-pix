.import "../../db/Query.js" as Q
.import org.kde.mauikit 1.0 as Maui

function refreshViews()
{
    galleryView.refresh()
    foldersView.refresh()
}

function addTagToPic(myTag, url)
{
    return tag.tagUrl(url, myTag)
}

function addTagToAlbum(tag, url)
{
    return dba.albumTag(tag, url)
}

function removePics(urls)
{
    for(var i in urls)
        dba.deletePic( urls[i])

    switch(currentView)
    {
    case views.gallery :
        galleryView.list.refresh()
        break
    case views.folders:
        foldersView.picsView.list.refresh();
        break
    case views.albums:
        albumsView.refreshPics()
        break
    case views.tags:
        tagsView.refreshPics()
        break
    case views.search:
        searchView.refreshPics()
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

function selectItem(item)
{
    selectionBox.append(item.url, item)
}


