.import "../Pix.js" as PIX
.import "../../../db/Query.js" as Q
.import org.kde.mauikit 1.0 as Maui
.import org.maui.pix 1.0 as Pix

function open(model, index)
{
    pixViewer.currentModel = model
    view(index)
    _actionGroup.currentIndex = views.viewer
}

function openExternalPics(pics, index)
{
    var oldIndex = pixViewer.viewer.count
    pixViewer.viewer.appendPics(pics)
    view(Math.max(oldIndex, 0))
    _actionGroup.currentIndex = views.viewer
}

function view(index)
{
    pixViewer.currentPicIndex = index
    pixViewer.currentPic = pixViewer.currentModel.get(pixViewer.currentPicIndex)

    if(Maui.FM.isCloud(pixViewer.currentPic.source))
        cloudView.list.requestImage(pixViewer.currentPicIndex)

    console.log("CURRENT PIC FAV", pixViewer.currentPic.fav)
    pixViewer.currentPicFav = Pix.DB.isFav(pixViewer.currentPic.url)
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
    for(const i in urls)
    {
        const url = urls[i]
        const faved = Pix.DB.isFav(url);

        if(Pix.DB.favPic(url, !faved))
            if(urls.length === 1)
                return !faved
    }
}




