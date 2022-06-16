// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import "../widgets/views/Viewer/Viewer.js" as VIEWER

Maui.SelectionBar
{
    id: control

    onExitClicked:
    {
        root.selectionMode = false
        clear()
    }

    onVisibleChanged:
    {
        if(!visible)
        {
            root.selectionMode = false
        }
    }

    listDelegate: Maui.ListBrowserDelegate
    {
        height: Maui.Style.toolBarHeight
        width: ListView.view.width
        isCurrentItem: false

        label1.text: model.title
        label2.text: model.url
        imageSource: model.url
        iconSizeHint: height * 0.9
        checked: true
        onToggled: control.removeAtIndex(index)

        background: Item {}
    }

    Action
    {
        text: i18n("View")
        icon.name: "document-preview-archive"
        onTriggered: VIEWER.openExternalPics(control.uris, 0)
    }


    Action
    {
        text: i18n("Tag")
        icon.name: "tag"
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.composerList.urls = control.uris
            dialog.open()
        }
    }

    Action
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered:
        {
            Maui.Platform.shareFiles(control.uris)
        }
    }

    hiddenActions:
        [
        Action
        {
            text: i18n("Un/Fav")
            icon.name: "love"
            onTriggered: VIEWER.fav(control.uris)
        },

        Action
        {
            text: i18n("Export")
            icon.name: "document-save"
            onTriggered:
            {
                const pics = control.uris
                dialogLoader.sourceComponent= fmDialogComponent
                dialog.show(function(paths)
                {
                    for(var i in paths)
                        FB.FM.copy(pics, paths[i])
                });
            }
        },

        Action
        {
            text: i18n("Remove")
            icon.name: "edit-delete"
            Maui.Theme.textColor: Maui.Theme.negativeTextColor
            onTriggered:
            {
                dialogLoader.sourceComponent = _removeDialogComponent
                dialog.open()
            }
        }
    ]
}

