function refreshViews()
{
    galleryView.clear()
    foldersView.clear()

    galleryView.populate()
    foldersView.populate()
}

function addTag(tag, url)
{
     return pix.picTag(tag, url)
}
