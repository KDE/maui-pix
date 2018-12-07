.import "../Pix.js" as PIX
.import "../../../db/Query.js" as Q
.import org.kde.mauikit 1.0 as Maui

function open(list, index)
{
    pixViewer.model.list = list
    view(index)

    if(currentView !== views.viewer)
        currentView = views.viewer

}

function openExternalPics(pics, index)
{
    pixViewer.viewer.populate(pics)
    view(index)
    if(currentView !== views.viewer)
        currentView = views.viewer
}

function view(index)
{
    pixViewer.currentPicIndex = index
    pixViewer.currentPic = pixViewer.model.list.get(pixViewer.currentPicIndex)

    if(Maui.FM.isCloud(pixViewer.currentPic.source))
        cloudView.list.requestImage(pixViewer.currentPicIndex)

    console.log("CURRENT PIC FAV", pixViewer.currentPic.fav)
    pixViewer.currentPicFav = dba.isFav(pixViewer.currentPic.url)
    root.title = pixViewer.currentPic.title

    pixViewer.roll.position(pixViewer.currentPicIndex)
}

function next()
{
    if(pixViewer.viewer.count > 0)
    {
        if(pixViewer.currentPicIndex < pixViewer.viewer.count)
            pixViewer.currentPicIndex++
        else
            pixViewer.currentPicIndex = 0

        view(pixViewer.currentPicIndex)
    }
}

function previous()
{
    if(pixViewer.viewer.count > 0)
    {
        if(pixViewer.currentPicIndex > 0)
            pixViewer.currentPicIndex--
        else
            pixViewer.currentPicIndex = pixViewer.viewer.count-1

        view(pixViewer.currentPicIndex)
    }
}

function fav(urls)
{
    for(var i in urls)
    {
        var url = urls[i]
        var faved = dba.isFav(url);

        if(dba.favPic(url, !faved))
            if(urls.length === 1)
                return !faved
    }
}




