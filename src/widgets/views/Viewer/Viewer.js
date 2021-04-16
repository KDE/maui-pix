// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


.import org.mauikit.filebrowsing 1.2 as FB

function open(model, index)
{
    _stackView.push(_pixViewer)
    _stackView.currentItem.model = model
    _stackView.currentItem.view(index)
}

function openExternalPics(pics, index)
{
    _stackView.push(_pixViewer)

    var oldIndex = _stackView.currentItem.viewer.count
    _stackView.currentItem.viewer.appendPics(pics)
    _stackView.currentItem.view(Math.max(oldIndex, 0))
}

function fav(urls)
{
    for(const i in urls)
        FB.Tagging.toggleFav(urls[i])
}




