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
    return pix.picTag(tag, url)
}

function addTagToAlbum(tag, url)
{
    return pix.albumTag(tag, url)
}

function removePic(url)
{
    if(pix.removeFile(url))
        refreshViews()
}

function addTagsToPic(tags, url)
{
    for(var i in tags)
        addTagToPic(tags[i], url)
}

function updatePicTags(tags, url)
{
    var oldTags = pix.get(Q.Query.picTags_.arg(pixViewer.currentPic.url))
    for(var i in oldTags)
        pix.removePicTag(oldTags[i].tag, url)

    addTagsToPic(tags, url)
}
