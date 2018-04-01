.import "../Pix.js" as PIX


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
    pixViewer.tagBar.tagsList.populate(pixViewer.currentPic.url)
    root.title = pixViewer.currentPic.title
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

    if(!faved)
    {
        if(PIX.addTag("fav", pixViewer.currentPic.url))
            pixViewer.tagBar.tagsList.model.insert(0, {"tag": "fav"})
    }else
    {
        if(pix.removePicTag("fav", pixViewer.currentPic.url))
            pixViewer.tagBar.tagsList.populate(pixViewer.currentPic.url)

    }


    if(pix.favPic(url, !faved))
        return !faved
}



