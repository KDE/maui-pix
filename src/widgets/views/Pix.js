// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

function selectItem(item)
{
    if(selectionBox.contains(item.url))
    {
        selectionBox.removeAtUri(item.url)
        return
    }

    selectionBox.append(item.url, item)
}


