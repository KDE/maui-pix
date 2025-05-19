pragma ComponentBehavior: Unbound

import QtQuick
import QtQuick.Controls

import "views"
import "views/Viewer"

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.mauikit.imagetools as IT
import org.maui.pix as Pix
import org.mauikit.imagetools.editor as ITEditor

Item
{
    id: control
    Keys.enabled: true
    Keys.forwardTo: _stackView

    property QtObject tagsDialog : null

    readonly property alias pixViewer : _pixViewer
    readonly property alias viewer : _pixViewer.viewer
    readonly property alias stackView : _stackView
    readonly property alias collectionViewComponent : _collectionViewComponent

    Action
    {
        id: _openSettingsAction
        text: i18n("Settings")
        icon.name: "settings-configure"
        onTriggered: openSettingsDialog()
    }

    Component
    {
        id: _mainMenuComponent

        Maui.ToolButtonMenu
        {
            id: _menu
            icon.name: "overflow-menu"

            MenuItem
            {
                text: i18n("Open")
                icon.name: "folder-open"
                onTriggered: openFileDialog()
            }

            MenuSeparator {}


            MenuItem
            {
                action: _openSettingsAction
            }

            MenuItem
            {
                text: i18n("About")
                icon.name: "documentinfo"
                onTriggered: Maui.App.aboutDialog()
            }
        }
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent
        objectName: "MainView"

        focus: false
        focusPolicy: Qt.NoFocus

        Keys.enabled: true
        Keys.onEscapePressed:
        {
            if(selectionBox.visible)
            {
                selectionBox.clear()
                return
            }
            _stackView.pop()
        }

        Keys.forwardTo: [currentItem]

        function forceActiveFocus()
        {
            _stackView.currentItem.forceActiveFocus()
        }

        initialItem: _pixViewer

        PixViewer
        {
            id: _pixViewer

            readonly property bool active: StackView.status === StackView.Active
            Maui.Controls.showCSD: true

            headBar.farRightContent: Loader
            {
                asynchronous: true
                sourceComponent: _mainMenuComponent
            }
        }
    }

    Component
    {
        id: _collectionViewComponent
        CollectionView {}
    }

    property int lastEditorAction : ITEditor.ImageEditor.ActionType.Colors
    Component
    {
        id: _editorComponent

        ITEditor.ImageEditor
        {
            id: _editor
            Maui.Controls.showCSD: true
            initialActionType: lastEditorAction
            Maui.Notification
            {
                id: _confirmNotification
                property var func: ({})
                title: i18n("Image Modified")
                message: i18n("The image has been edited. Save or discard the changes before continuing")
                iconName: _editor.url
                Action
                {
                    text: i18n("Discard")
                    onTriggered:
                    {
                        _editor.editor.cancel()
                        _confirmNotification.func()
                    }
                }
            }

            Keys.enabled: true
            Keys.onPressed: (event) => {
                if(event.key === Qt.Key_Left)
                {
                    _goPreviousAction.trigger()
                    event.accepted = true
                    return
                }

                if(event.key === Qt.Key_Right)
                {
                    _goNextAction.trigger()
                    event.accepted = true
                    return
                }
            }

            function editNextImage()
            {
                var index = _editor.StackView.view.depth - 2
                var item = _editor.StackView.view.get(index, StackView.DontLoad)
                var url = item.nextUrl()
                _editor.url = url
                _editor.forceActiveFocus()
            }

            function editPreviousImage()
            {
                var index = _editor.StackView.view.depth - 2
                var item = _editor.StackView.view.get(index, StackView.DontLoad)
                var url = item.previousUrl()
                _editor.url = url
                _editor.forceActiveFocus()
            }

            headBar.leftContent: Maui.ToolActions
            {
                checkable:false
                autoExclusive: false

                Action
                {
                    id: _goPreviousAction
                    icon.name: "go-previous"
                    onTriggered:
                    {
                        if(_editor.editor.edited)
                        {
                            _confirmNotification.func = _editor.editPreviousImage
                            _confirmNotification.dispatch()
                            return
                        }
                        _editor.editPreviousImage()
                    }
                }

                Action
                {
                    id: _goNextAction
                    icon.name: "go-next"
                    onTriggered:
                    {
                        if(_editor.editor.edited)
                        {
                            _confirmNotification.func = _editor.editNextImage
                            _confirmNotification.dispatch()
                            return
                        }
                        _editor.editNextImage()
                    }
                }
            }

            onSaved:
            {
                lastEditorAction = getCurrentActionType()
                _saveNotification.url = url
                _editor.StackView.view.pop()

                if(!pixViewer.active)
                {
                    _saveNotification.dispatch()
                }
            }

            onCanceled:
            {
                console.log("Image edited? ", editor.edited)
                lastEditorAction = getCurrentActionType()

                if(!editor.edited)
                {
                    _editor.StackView.view.pop()
                    return
                }
            }
        }
    }

    Maui.Notification
    {
        id: _saveNotification
        iconSource: url
        title: i18n("Saved")
        message: i18n("The image has been saved correctly.")
        property string url
        Action
        {
            text: i18n("View")
            onTriggered: openExternalPics([_saveNotification.url], 0)
        }
    }

    Loader
    {
        anchors.fill: parent
        visible: _dropAreaLoader.item.containsDrag
        asynchronous: true

        sourceComponent: Rectangle
        {
            color: Qt.rgba(Maui.Theme.backgroundColor.r, Maui.Theme.backgroundColor.g, Maui.Theme.backgroundColor.b, 0.95)

            Maui.Rectangle
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                color: "transparent"
                borderColor: Maui.Theme.textColor
                solidBorder: false

                Maui.Holder
                {
                    anchors.fill: parent
                    visible: true
                    emoji: "qrc:/img/assets/add-image.svg"
                    emojiSize: Maui.Style.iconSizes.huge
                    title: i18n("Open images")
                    body: i18n("Drag and drop images here.")
                }
            }
        }
    }

    Loader
    {
        id: _dropAreaLoader
        anchors.fill: parent

        sourceComponent: DropArea
        {
            onDropped: (drop) =>
                       {
                if(drop.urls)
                {
                    openExternalPics(drop.urls, 0)
                }
            }

            onEntered: (drag) =>
                       {
                if(drag.source)
                {
                    return
                }

                if(!_pixViewer.active)
                {
                    _stackView.push(_pixViewer)
                }
            }
        }
    }

    Component
    {
        id: _infoDialogComponent
        IT.ImageInfoDialog
        {
            onGpsEdited:(url) => Pix.Collection.allImagesModel.updateGpsTag(url)
            onClosed: destroy()
        }
    }

    Component
    {
        id: tagsDialogComponent

        FB.TagsDialog
        {
            Maui.Notification
            {
                id: _taggedNotification
                iconName: "dialog-info"
                title: i18n("Tagged")
                message: i18n("File was tagged successfully")

                Action
                {
                    property string tag
                    id: _openTagAction
                    text: tag
                    enabled: tag.length > 0
                    onTriggered:
                    {
                        openFolder("tags:///"+tag)
                    }
                }
            }

            onTagsReady: (tags) =>
                         {
                if(tags.length === 1)
                {
                    _openTagAction.tag = tags[0]
                    _taggedNotification.dispatch()
                }
                browserSettings.lastUsedTag = tags[0]
                composerList.updateToUrls(tags)
            }

            composerList.strict: false
        }
    }

    Component
    {
        id: fmDialogComponent
        FB.FileDialog
        {
            mode: FB.FileDialog.Open
            onClosed: destroy()
        }
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog
        {
            onClosed:
            {
                destroy()
            }
        }
    }

    Component
    {
        id: _removeDialogComponent

        FB.FileListingDialog
        {
            id: removeDialog
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
                        FB.FM.removeFiles(removeDialog.urls)
                        selectionBox.clear()
                        close()
                    }
                }
            ]
        }
    }

    FB.OpenWithDialog
    {
        id: _openWithDialog
    }

    function setPreviewSize(size)
    {
        console.log(size)
        browserSettings.previewSize = size
    }

    function getFileInfo(url)
    {
        var dialog = _infoDialogComponent.createObject(control, ({'url': url}))
        dialog.open()
    }

    function toogleTagbar()
    {
        viewerSettings.tagBarVisible = !viewerSettings.tagBarVisible
    }

    function tooglePreviewBar()
    {
        viewerSettings.previewBarVisible = !viewerSettings.previewBarVisible
    }

    function toggleViewer()
    {
        if(_pixViewer.active)
        {
            if(_stackView.depth === 1)
            {
                _stackView.replace(_pixViewer, _collectionViewComponent)

            }else
            {
                _stackView.pop()
            }

        }else
        {
            _stackView.push(_pixViewer)
        }

        _stackView.currentItem.forceActiveFocus()
    }

    function openFileDialog()
    {
        let props = ({ 'browser.settings.filterType' : FB.FMList.IMAGE,
                         'callback' : function(paths)
                         {
                             openExternalPics(paths)
                         }})
        var dialog = fmDialogComponent.createObject(control, props)
        dialog.open()
    }

    function openSettingsDialog()
    {
        var dialog = _settingsDialogComponent.createObject(control)
        dialog.open()
    }

    function openFolder(url : string, filters : var)
    {
        if(pixViewer.active)
        {
            toggleViewer()
        }

        _stackView.currentItem.openFolder(url, filters)
    }

    function openEditor(url, stack)
    {
        stack.push(_editorComponent, ({url: url}))
    }

    function openExternalPics(pics, index)
    {
        var oldIndex = pics.lenght-1
        pixViewer.viewer.clear()
        pixViewer.viewer.appendPics(pics)
        pixViewer.view(Math.max(oldIndex, index, 0))
        if(!pixViewer.active)
        {
            toggleViewer()
        }
    }

    function open(model, index, recursive = false)
    {
        pixViewer.model.list.recursive = model.list.recursive
        pixViewer.model.list.urls = model.list.urls

        pixViewer.view( pixViewer.model.mappedFromSource(index))
        if(!pixViewer.active)
        {
            toggleViewer()
        }
    }

    function openTagsDialog(urls)
    {
        if(control.tagsDialog)
        {
            control.tagsDialog.composerList.urls = urls
        }else
        {
            control.tagsDialog = tagsDialogComponent.createObject(control, ({'composerList.urls' : urls}))
        }

        control.tagsDialog.open()
    }

    function saveAs(urls)
    {
        let pic = urls[0]
        let props = ({'mode' : FB.FileDialog.Save,
                         'browser.settings.filterType' : FB.FMList.IMAGE,
                         'singleSelection' : true,
                         'suggestedFileName' : FB.FM.getFileInfo(pic).label,
                         'callback' : function(paths)
                         {
                             console.log("Sate to ", paths)
                             FB.FM.copy(urls, paths[0])

                         }})
        var dialog = fmDialogComponent.createObject(control, props)
        dialog.open()
    }

    function removeFiles(urls)
    {
        var dialog = _removeDialogComponent.createObject(control, ({'urls' : urls}))
        dialog.open()
    }

    function openFileWith(urls)
    {
        if(Maui.Handy.isAndroid)
        {
            FB.FM.openUrl(item.url)
            return
        }

        _openWithDialog.urls = urls
        _openWithDialog.open()
    }
}
