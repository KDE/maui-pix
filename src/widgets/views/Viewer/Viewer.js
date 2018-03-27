function view(model, index)
{
    console.log(model.length, index)
    pixViewer.currentPicIndex = index
    pixViewer.picContext = model
    console.log(pixViewer.picContext.length, pixViewer.currentPicIndex)
    pixViewer.currentPic = pixViewer.picContext[pixViewer.currentPicIndex]
    console.log(model[7].url)
    if(currentView !== views.viewer)
        currentView = views.viewer

}

function fullscreen()
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

        pixViewer.currentPic = pixViewer.picContext[pixViewer.currentPicIndex]
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

        pixViewer.currentPic = pixViewer.picContext[pixViewer.currentPicIndex]
    }
}

function fav(url)
{

}

