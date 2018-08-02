.import "../Pix.js" as PIX
.import "../../../db/Query.js" as Q


function open(model, index)
{
    pixViewer.viewer.list.model = model
    pixViewer.roll.rollList.model = pixViewer.viewer.list.model

    view(index)

    if(currentView !== views.viewer)
        currentView = views.viewer

}

function openExternalPics(pics, index)
{
    pixViewer.viewer.populate(pics)
    pixViewer.roll.rollList.model = pixViewer.viewer.list.model
    view(index)
    if(currentView !== views.viewer)
        currentView = views.viewer
}

function view(index)
{
    pixViewer.currentPicIndex = index

    pixViewer.currentPic = pixViewer.viewer.list.model.get(pixViewer.currentPicIndex)

    pixViewer.currentPicFav = pix.isFav(pixViewer.currentPic.url)
    setCurrentPicTags()

    root.title = pixViewer.currentPic.title

    pixViewer.roll.position(pixViewer.currentPicIndex)
}

function setCurrentPicTags()
{
    pixViewer.tagBar.populate(tag.getUrlTags(pixViewer.currentPic.url))
}


function next()
{
    if(pixViewer.viewer.list.count > 0)
    {
        if(pixViewer.currentPicIndex < pixViewer.viewer.list.count)
            pixViewer.currentPicIndex++
        else
            pixViewer.currentPicIndex = 0

        view(pixViewer.currentPicIndex)
    }
}

function previous()
{
    if(pixViewer.viewer.list.count > 0)
    {
        if(pixViewer.currentPicIndex > 0)
            pixViewer.currentPicIndex--
        else
            pixViewer.currentPicIndex = pixViewer.viewer.list.count-1

        view(pixViewer.currentPicIndex)
    }
}

function fav(urls)
{
    for(var i in urls)
    {
        var url = urls[i]

        if(!pix.checkExistance("images", "url", url))
            if(!pix.addPic(url))
                return

        var faved = pix.isFav(url);

        //        if(!faved)
        //        {
        //            if(PIX.addTagToPic("fav", pixViewer.currentPic.url))
        //                pixViewer.tagBar.tagsList.model.insert(0, {"tag": "fav"})
        //        }else
        //        {
        //            if(pix.removePicTag("fav", pixViewer.currentPic.url))
        //                pixViewer.tagBar.tagsList.populate(pixViewer.currentPic.url)

        //        }

        if(pix.favPic(url, !faved))
            if(urls.length === 1)
                return !faved
    }
}




