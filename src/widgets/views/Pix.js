function refreshViews()
{
    galleryView.clear()
    foldersView.clear()

    galleryView.populate()
    foldersView.populate()
    albumsView.populate()
}

function addTagToPic(tag, url)
{
     return pix.picTag(tag, url)
}

function addTagToAlbum(tag, url)
{
     return pix.albumTag(tag, url)
}
