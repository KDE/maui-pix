// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami
import org.maui.pix 1.0 as Pix
import "../widgets/views/Pix.js" as PIX

Menu
{
    id: control

    property bool isFav : false
    property int index : -1
    property Maui.BaseModel model : null

    onOpened: isFav = Maui.FM.isFav(control.model.get(index).url)

    MenuItem
    {
        text: i18n("Select")
        icon.name: "item-select"
        onTriggered:
        {
            if(Kirigami.Settings.isMobile)
                selectionMode = true

            PIX.selectItem(control.model.get(index))
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n(isFav ? "UnFav it": "Fav it")
        icon.name: "love"
        onTriggered: Maui.FM.toggleFav(control.model.get(index).url)
    }

    MenuItem
    {
        text: i18n("Tags")
        icon.name: "tag"
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.composerList.urls = [control.model.get(index).url]
            dialog.open()
        }
    }

    MenuItem
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered:
        {
            dialogLoader.sourceComponent = shareDialogComponent
            dialog.urls= [control.model.get(index).url]
            dialog.open()
        }
    }

    MenuItem
    {
        text: i18n("Export")
        icon.name: "document-save-as"
        onTriggered:
        {
            var pic = control.model.get(index).url
            dialogLoader.sourceComponent= fmDialogComponent
            dialog.mode = dialog.modes.SAVE
            dialog.suggestedFileName= Maui.FM.getFileInfo(control.model.get(index).url).label
            dialog.show(function(paths)
            {
                for(var i in paths)
                    Maui.FM.copy(pic, paths[i])
            });
            close()
        }
    }

    MenuItem
    {
        visible: !isAndroid
        text: i18n("Show in folder")
        icon.name: "folder-open"
        onTriggered:
        {
            Pix.Collection.showInFolder([control.model.get(index).url])
            close()
        }
    }

    MenuItem
    {
        visible: !isAndroid
        text: i18n("Info")
        icon.name: "documentinfo"
        onTriggered:
        {
            getFileInfo(control.model.get(index).url)
            close()
        }
    }

    //    Maui.MenuItem
    //    {
    //        text: i18n("Copy")
    //        onTriggered:
    //        {
    //            Maui.Handy.copyToClipboard(paths.join(","))
    //            control.close()
    //        }
    //    }

    MenuSeparator{}


    MenuItem
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
            close()
        }

        Maui.Dialog
        {
            id: removeDialog

            title: i18n("Delete file?")
            acceptButton.text: i18n("Accept")
            rejectButton.text: i18n("Cancel")
            message: i18n("Are sure you want to delete %1".arg(control.model.get(index).url))
            page.padding: Maui.Style.space.huge
            onRejected: close()
            onAccepted:
            {
                control.model.list.deleteAt(control.index)
                close()
            }
        }

    }

}
