import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.kde.kirigami 2.8 as Kirigami

import org.maui.pix 1.0 as Pix

Maui.ContextualMenu
{
    id: control

    property bool isFav : false
    property int index : -1
    property Maui.BaseModel model : null

    onOpened: isFav = FB.Tagging.isFav(control.model.get(index).url)

    Maui.FileListingDialog
    {
        id: removeDialog
        parent: control.parent
        urls: filterSelection(control.model.get(index).url)
        title: i18n("Delete file?")
        acceptButton.text: i18n("Accept")
        rejectButton.text: i18n("Cancel")
        message: i18nc("Remove one file", "Are sure you want to delete this file? This action can not be undone.")

        onRejected: close()
        onAccepted:
        {
            control.model.list.deleteAt(model.mappedToSource(control.index))
            close()
        }
    }

    MenuItem
    {
        text: i18n("Select")
        icon.name: "item-select"
        onTriggered:
        {
            if(Maui.Handy.isTouch)
                root.selectionMode = true

            selectItem(control.model.get(index))
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n(isFav ? "UnFav it": "Fav it")
        icon.name: "love"
        onTriggered: FB.Tagging.toggleFav(control.model.get(index).url)
    }

    MenuItem
    {
        text: i18n("Tags")
        icon.name: "tag"
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.composerList.urls = filterSelection(control.model.get(index).url)
            dialog.open()
        }
    }

    MenuItem
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered:
        {
            Maui.Platform.shareFiles(filterSelection(control.model.get(index).url))
        }
    }

    MenuItem
    {
        text: i18n("Open With")
        icon.name: "document-open"
        onTriggered:
        {
            _openWithDialog.urls = filterSelection(control.model.get(index).url)
            _openWithDialog.open()
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
            dialog.suggestedFileName= FB.FM.getFileInfo(control.model.get(index).url).label
            dialog.show(function(paths)
            {
                for(var i in paths)
                    FB.FM.copy(pic, paths[i])
            });
        }
    }

    MenuItem
    {
        visible: !Maui.Handy.isAndroid
        text: i18n("Show in folder")
        icon.name: "folder-open"
        onTriggered:
        {
            Pix.Collection.showInFolder(filterSelection(control.model.get(index).url))
        }
    }

    MenuItem
    {
        text: i18n("Info")
        icon.name: "documentinfo"
        onTriggered:
        {
            getFileInfo(control.model.get(index).url)
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
        }
    }
}
