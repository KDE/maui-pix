function open(model, index)
{
    pixViewer.currentPicIndex = index
    pixViewer.picContext = model

    view(pixViewer.currentPicIndex)

    if(currentView !== views.viewer)
        currentView = views.viewer

}

function view(index)
{
    pixViewer.currentPic = pixViewer.picContext[index]
    pixViewer.currentPicFav = pix.isFav(pixViewer.currentPic.url)
    pixViewer.tagBar.populate(pixViewer.currentPic.url)
}

function fullscreen(state)
{

}

function next()
{
    if(pixViewer.picContext && pixViewer.picContext.length > 0)
    {
        if(pixViewer.currentPicIndex < pixViewer.picContext.length)
            pixViewer.currentPicIndex++
        else
            pixViewer.currentPicIndex = 0

        view(pixViewer.currentPicIndex)
    }
}

function previous()
{
    if(pixViewer.picContext && pixViewer.picContext.length > 0)
    {
        if(pixViewer.currentPicIndex > 0)
            pixViewer.currentPicIndex--
        else
            pixViewer.currentPicIndex = pixViewer.picContext.length-1

        view(pixViewer.currentPicIndex)
    }
}

function fav(url)
{
    var faved = pix.isFav(url);
    if(pix.favPic(url, !faved))
        return !faved
}

