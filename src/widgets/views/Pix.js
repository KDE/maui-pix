function refreshViews()
{
    galleryView.clear()
    foldersView.clear()
    tagsView.clear()

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
