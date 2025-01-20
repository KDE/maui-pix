// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


.import org.mauikit.filebrowsing 1.2 as FB

function open(model, index, recursive = false)
{
    _pixViewer.model.list.recursive = model.list.recursive
    _pixViewer.model.list.urls = model.list.urls
    _pixViewer.view(index)
    if(!_pixViewer.visible)
    {
        toggleViewer()
    }
}

function openExternalPics(pics, index)
{
    var oldIndex = _pixViewer.viewer.count
    _pixViewer.viewer.appendPics(pics)
    _pixViewer.view(Math.max(oldIndex, 0))
    if(!_pixViewer.visible)
    {
        toggleViewer()
    }
}

function fav(urls)
{
    for(const i in urls)
        FB.Tagging.toggleFav(urls[i])
}




