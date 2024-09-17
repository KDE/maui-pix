import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.pix as Pix

Maui.ContextualMenu
{
    id: control

    property bool isFav : false
    property int index : -1
    property Maui.BaseModel model : null
    property var item : ({})
    readonly property string totalCount : filterSelection(item.url).length > 1 ? filterSelection(item.url).length : ""

<<<<<<< HEAD
    property alias editMenuItem : _editMenuItem
    onOpened:
=======
    onOpened: isFav = FB.Tagging.isFav(item.url)

    title: control.item.title
//    subtitle: Maui.Handy.formatSize(control.item.size)
    titleImageSource: control.item.url
    titleIconSource: control.item.icon

    FB.FileListingDialog
>>>>>>> 452912c (update to android 11+. fix openwith action on android. typo fixes)
    {
        if(control.model &&  control.index >= 0 )
        {
         control.item = control.model.get(control.index)
        }

        control.isFav = FB.Tagging.isFav(control.item.url)
    }

    Maui.Controls.component: Maui.IconItem
    {
        visible: !pixViewer.active
        imageSource: control.item.url
        fillMode: Image.PreserveAspectCrop
        implicitHeight: visible ? 50 : 0
        maskRadius: Maui.Style.radiusV
    }

    Maui.MenuItemActionRow
    {
        Action
        {
            text: i18n(isFav ? "UnFav it": "Fav it")
            checked: isFav
            checkable: true
            icon.name: "love"
            onTriggered: FB.Tagging.toggleFav(item.url)
        }

        Action
        {
            text: i18n("Info")
            icon.name: "documentinfo"
            onTriggered:
            {
                getFileInfo(item.url)
            }
        }

        Action
        {
            text: i18n("Share")
            icon.name: "document-share"
            onTriggered:
            {
                Maui.Platform.shareFiles(filterSelection(item.url))
            }
        }
    }

    MenuSeparator{}

    MenuItem
    {
        enabled: typeof selectionBox !== "undefined"
        visible: enabled
        height: visible ? implicitHeight : -control.spacing
        text: i18n("Select")
        icon.name: "item-select"
        onTriggered:
        {
            if(Maui.Handy.isTouch)
                root.selectionMode = true

            selectItem(item)
        }
    }

    MenuItem
    {
        text: i18n("Open in New Window")
        icon.name: "window-new"
        onTriggered:
        {
            root.view(filterSelection(item.url), true)
        }
    }


    MenuSeparator{}

    MenuItem
    {
        visible: browserSettings.lastUsedTag.length > 0
        height: visible ? implicitHeight : -control.spacing
        text: i18n("Add to '%1'", browserSettings.lastUsedTag)
        icon.name: "tag"
        onTriggered:
        {
            FB.Tagging.tagUrl(control.item.url, browserSettings.lastUsedTag)
        }
    }

    MenuItem
    {
        text: i18n("Add to Album")
        icon.name: "tag"
        Maui.Controls.badgeText: control.totalCount

        onTriggered:
        {
            openTagsDialog(filterSelection(item.url))
            _selectionBar.clear()
        }
    }

    MenuSeparator{}

    MenuItem
    {
        id: _editMenuItem
        text: i18n("Edit")
        icon.name: "document-edit"
        onTriggered:
        {
            if(action)
                return
            openEditor(item.url, _stackView)
        }
    }

    MenuItem
    {
        text: i18n("Save as")
        icon.name: "document-save-as"
        onTriggered: saveAs([item.url])
    }

    MenuItem
    {
        text: i18n("Open with")
        icon.name: "document-open"
        Maui.Controls.badgeText: control.totalCount
        onTriggered: openFileWith(filterSelection(item.url))
    }

    MenuItem
    {
        text: i18n("Go to Folder")
        icon.name: "folder-open"
        onTriggered:
        {
            if(pixViewer.active)
            {
                toggleViewer()
            }

            var url = FB.FM.fileDir(item.url)
            openFolder(url)
        }
    }

    MenuItem
    {
        enabled: !Maui.Handy.isAndroid
        text: i18n("Open Location")
        icon.name: "folder-open"
        onTriggered:
        {
            Pix.Collection.showInFolder(filterSelection(item.url))
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Maui.Controls.badgeText: control.totalCount
        Maui.Controls.status: Maui.Controls.Negative
        onTriggered: removeFiles(filterSelection(item.url))
    }
}
