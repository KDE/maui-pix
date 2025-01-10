// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

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
        width: ListView.view.width
        isCurrentItem: false

        label1.text: model.title
        label2.text: model.url
        imageSource: model.url
        // iconSizeHint: 48
        iconSizeHint: Maui.Style.iconSizes.big
        height: Maui.Style.iconSizes.big + Maui.Style.space.big
        checked: true
        checkable: true

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
            icon.name: "document-export"
            onTriggered:
            {
                const pics = control.uris
                dialogLoader.sourceComponent = null
                dialogLoader.sourceComponent = fmDialogComponent
                dialog.browser.settings.onlyDirs = true
                dialog.singleSelection = true
                dialog.callback = function(paths)
                {
                    FB.FM.copy(pics, paths[0])
                }
                dialog.open()
            }
        },

        Action
        {
            text: i18n("Remove")
            icon.name: "edit-delete"
            Maui.Controls.status: Maui.Controls.Negative

            onTriggered:
            {
                dialogLoader.sourceComponent = _removeDialogComponent
                dialog.urls = control.uris
                dialog.open()
            }
        }
    ]
}

