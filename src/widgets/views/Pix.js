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
