// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


.import "../Pix.js" as PIX
.import org.kde.mauikit 1.0 as Maui
.import org.maui.pix 1.0 as Pix

function open(model, index)
{
    pixViewer.model = model
    view(index)
}

function openExternalPics(pics, index)
{
    var oldIndex = pixViewer.viewer.count
    pixViewer.viewer.appendPics(pics)
    view(Math.max(oldIndex, 0))
}

function view(index)
{
    pixViewer.currentPicIndex = index
    pixViewer.currentPic = pixViewer.model.get(pixViewer.currentPicIndex)

    pixViewer.currentPicFav = Maui.FM.isFav(pixViewer.currentPic.url)
    root.title = pixViewer.currentPic.title
    swipeView.currentIndex = views.viewer
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
        Maui.FM.toggleFav(urls[i])
}




