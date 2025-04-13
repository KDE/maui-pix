// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


/***
Pix  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Layouts

import QtQuick.Window

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.mauikit.imagetools as IT
import org.maui.pix as Pix
import org.mauikit.imagetools.editor as ITEditor

import "widgets"
import "widgets/views"
import "widgets/views/Viewer"

import "widgets/views/Viewer/Viewer.js" as VIEWER

Maui.ApplicationWindow
{
    id: root
    title: initData

    Maui.Style.styleType: _pixViewer.visible ? Maui.Style.Dark : undefined

    readonly property alias dialog : dialogLoader.item

    readonly property bool fullScreen : root.visibility === Window.FullScreen

    readonly property var previewSizes: ({small: 72,
                                             medium: 90,
                                             large: 120,
                                             extralarge: 160})
    property bool selectionMode : false

    readonly property bool editing : control.currentItem.objectName === "imageEditor"


    Settings
    {
        id: browserSettings
        category: "Browser"
        property bool showLabels : false
        property bool fitPreviews : false
        property bool autoReload: true
        property int previewSize : previewSizes.medium
        property string sortBy : "modified"
        property int sortOrder: Qt.DescendingOrder
        property bool gpsTags : false
        property string lastUsedTag
    }

    Settings
    {
        id: viewerSettings
        property bool tagBarVisible : true
        property bool previewBarVisible : false
        property bool enableOCR: Maui.Handy.isLinux
        property int ocrConfidenceThreshold: 40
        property int ocrBlockType : 0 // 0-word 1-line 2-paragraph
        property int ocrSelectionType: 0 //0-free 1-rectangular
        property bool ocrPreprocessing : false
        property int ocrSegMode: IT.OCR.Auto
    }

    Component
    {
        id: _mainMenuComponent
        Maui.ToolButtonMenu
        {
            icon.name: "overflow-menu"

            MenuItem
            {
                text: i18n("Open")
                icon.name: "folder-open"
                onTriggered: openFileDialog()
            }

            MenuSeparator {}

            Maui.FlexSectionItem
            {
                label1.text: i18n("Preview Size")
                label2.text: i18n("Size of the thumbnails in the collection views.")
                wide: false
                Maui.ToolActions
                {
                    id: _gridIconSizesGroup
                    expanded: true
                    autoExclusive: true
                    display: ToolButton.TextOnly
                    font.bold: true

                    Action
                    {
                        text: i18n("S")
                        onTriggered: setPreviewSize(previewSizes.small)
                        checked: previewSizes.small === browserSettings.previewSize
                    }

                    Action
                    {
                        text: i18n("M")
                        onTriggered: setPreviewSize(previewSizes.medium)
                        checked: previewSizes.medium === browserSettings.previewSize

                    }

                    Action
                    {
                        text: i18n("X")
                        onTriggered: setPreviewSize(previewSizes.large)
                        checked: previewSizes.large === browserSettings.previewSize

                    }

                    Action
                    {
                        text: i18n("XL")
                        onTriggered: setPreviewSize(previewSizes.extralarge)
                        checked: previewSizes.extralarge === browserSettings.previewSize

                    }
                }
            }



            MenuItem
            {
                text: i18n("Settings")
                icon.name: "settings-configure"
                onTriggered: openSettingsDialog()
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

        Keys.enabled: true
        Keys.onEscapePressed: _stackView.pop()

        initialItem: initModule === "viewer" ? _pixViewer : _collectionViewComponent

        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
        }

        Loader
        {
            id: _collectionViewComponent
            active:  StackView.status === StackView.Active || item
            property string pendingFolder : initModule === "folder" ? initData[0] : ""

            sourceComponent: CollectionView {}
        }

        PixViewer
        {
            id: _pixViewer
            visible: StackView.status === StackView.Active
            Maui.Controls.showCSD: true
        }
    }


    Component
    {
        id: _editorComponent

        ITEditor.ImageEditor
        {
            id: _editor
            onSaved:
            {
                _stackView.pop()
                // viewer.reloadCurrentItem()
            }

            onCanceled:
            {
                if(!_editor.edited)
                {
                    _stackView.pop()
                    return
                }
            }
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
                               VIEWER.openExternalPics(drop.urls, 0)
                           }
                       }

            onEntered: (drag) =>
                       {
                           if(drag.source)
                           {
                               return
                           }

                           if(!_pixViewer.visible)
                           _stackView.push(_pixViewer)
                       }
        }
    }

    Component
    {
        id: _infoDialogComponent
        IT.ImageInfoDialog {}
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
        }
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog {}
    }

    Component
    {
        id: _removeDialogComponent

        FB.FileListingDialog
        {
            id: removeDialog
            title: i18np("Delete %1 file?", "Delete %1 files?", urls.length)
            message: i18np("Are sure you want to delete this file? This action can not be undone.", "Are sure you want to delete these files? This action can not be undone.", urls.length)

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
                        _collectionViewComponent.item.selectionBox.clear()
                        close()
                    }
                }
            ]
        }
    }

    Loader { id: dialogLoader }

    FB.OpenWithDialog
    {
        id: _openWithDialog
    }

    Connections
    {
        target: Pix.Collection

        function onViewPics(pics)
        {
            VIEWER.openExternalPics(pics, 0)
        }
    }

    function setPreviewSize(size)
    {
        console.log(size)
        browserSettings.previewSize = size
    }

    function getFileInfo(url)
    {
        dialogLoader.sourceComponent= _infoDialogComponent
        dialog.url = url
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

    function toogleFullscreen()
    {
        if(root.visibility === Window.FullScreen)
        {
            root.showNormal()
        }else
        {
            root.showFullScreen()
        }
    }

    function toggleViewer()
    {
        if(_pixViewer.visible)
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
        dialogLoader.sourceComponent = null
        dialogLoader.sourceComponent = fmDialogComponent
        dialog.browser.settings.filterType = FB.FMList.IMAGE
        dialog.callback = function(paths)
        {
            Pix.Collection.openPics(paths)
        }
        dialog.open()
    }

    function openSettingsDialog()
    {
        dialogLoader.sourceComponent = _settingsDialogComponent
        dialog.open()
    }

    function openFolder(url, filters)
    {
        if(!_collectionViewComponent.visible)
        {
            toggleViewer()
        }

        _collectionViewComponent.item.openFolder(url, filters)
    }

    function openEditor(url)
    {
        _stackView.push(_editorComponent, ({url: url}))
    }
}
