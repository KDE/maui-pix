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
    readonly property var item : control.model.get(index)
    readonly property string totalCount : filterSelection(item.url).length > 1 ? filterSelection(item.url).length : ""

    onOpened: isFav = FB.Tagging.isFav(item.url)

    //     title: control.item.title
    // //    subtitle: Maui.Handy.formatSize(control.item.size)
    //     titleImageSource: control.item.url
    //     titleIconSource: control.item.icon

    Maui.Controls.component: Maui.IconItem
    {
        imageSource: control.item.url
        fillMode: Image.PreserveAspectCrop
        implicitHeight: 50
        maskRadius: Maui.Style.radiusV
    }

    Component
    {
        id: removeDialogComponent

        FB.FileListingDialog
        {
            id: removeDialog
            parent: control.parent
            urls: filterSelection(item.url)

            title: i18np("Delete %1 file?", "Delete %1 files?", urls.length)
            message: i18np("Are sure you want to delete this file? This action can not be undone.", "Are sure you want to delete these files? This action can not be undone.", urls.length)

            onClosed: destroy()
            actions:
                [
                Action
                {
                    text: i18n("Cancel")
                    onTriggered: removeDialog.close()
                },

                Action
                {
                    text: i18n("Remove")
                    Maui.Controls.status: Maui.Controls.Negative
                    onTriggered:
                    {
                        control.model.list.deleteAt(model.mappedToSource(control.index))
                        removeDialog.close()
                    }
                }
            ]
        }
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
            view(filterSelection(item.url))
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
        text: i18n("Edit")
        icon.name: "document-edit"
        onTriggered:
        {
            openEditor(item.url, _stackView)
        }
    }

    MenuItem
    {
        text: i18n("Save as")
        icon.name: "document-save-as"
        onTriggered:
        {
            let pic = item.url
            let props = ({'mode' : FB.FileDialog.Save,
            'browser.settings.filterType' : FB.FMList.IMAGE,
            'singleSelection' : true,
            'suggestedFileName' : FB.FM.getFileInfo(item.url).label,
            'callback' : function(paths)
            {
                FB.FM.copy([pic], paths[0])
            }})
            var dialog = fmDialogComponent.createObject(root, props)

            dialog.open()
        }
    }

    MenuItem
    {
        text: i18n("Open with")
        icon.name: "document-open"
        Maui.Controls.badgeText: control.totalCount
        onTriggered:
        {
            if(Maui.Handy.isAndroid)
            {
                FB.FM.openUrl(item.url)
                return
            }

            _openWithDialog.urls = filterSelection(item.url)
            _openWithDialog.open()
        }
    }

    MenuItem
    {
        text: i18n("Go to Folder")
        icon.name: "folder-open"
        onTriggered:
        {
            if(_pixViewer.visible)
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
        onTriggered:
        {
           var obj = removeDialogComponent.createObject()
            obj.open()
        }
    }
}
