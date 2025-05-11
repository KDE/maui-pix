// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// .pragma library
.import org.mauikit.filebrowsing as FB


function fav(urls)
{
    for(const i in urls)
        FB.Tagging.toggleFav(urls[i])
}

function openExternalPics(pics, index)
{
    appView.openExternalPics(pics, index)
}

function open(model, index, recursive = false)
{
    appView.open(model, index, recursive)
}

