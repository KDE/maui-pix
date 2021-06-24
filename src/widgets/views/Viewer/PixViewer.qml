// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.2 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.imagetools 1.0 as IT

import org.maui.pix 1.0 as Pix

import "../../../view_models"

StackView
{
    id: control

    property alias viewer : viewer
    property alias holder : holder
    property alias tagBar : tagBar
    property alias roll : galleryRoll
    readonly property bool editing : control.currentItem.objectName === "imageEditor"

    property bool currentPicFav: false
    property var currentPic : ({})
    property int currentPicIndex : 0
    property alias model :viewer.model
    property bool doodle : false    

    Component
    {
        id: _editorComponent

        IT.ImageEditor
        {
            objectName: "imageEditor"
            url: control.currentPic.url

            headBar.farLeftContent:  ToolButton
            {
                icon.name: "go-previous"
                onClicked:
                {
                    control.pop()
                }
            }

            headBar.rightContent:  Maui.ToolButtonMenu
            {
                icon.name: "document-save"

                MenuItem
                {
                    text: i18n("Save as")
                    icon.name: "document-save-as"
                    onTriggered:
                    {
                        dialogLoader.sourceComponent= fmDialogComponent
                        dialog.mode = dialog.modes.SAVE
                        dialog.settings.onlyDirs= false
                        dialog.singleSelection = true
                        dialog.callback = function(paths)
                        {
                            console.log("Save edit to", paths)
                            editor.saveAs(paths[0])
                        };
                        dialog.open()
                    }
                }

                MenuItem
                {
                    text: i18n("Save")
                    icon.name: "document-save"
                    onTriggered: editor.save()
                }
            }
        }
    }

    initialItem: Maui.Page
    {
        id: _viewer
        padding: 0
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        title: currentPic.title
        showTitle: root.isWide
        headBar.visible: true
        headerColorSet: Kirigami.Theme.Header
                floatingHeader: true
                autoHideHeader: true
        headBar.farLeftContent: [
            ToolButton
            {
                icon.name: "go-previous"
                text: i18n("Gallery")
                display: ToolButton.TextBesideIcon
                onClicked: _stackView.pop()
            }
        ]

        headBar.rightContent: ToolButton
        {
            visible: !Kirigami.Settings.isMobile
            icon.name: "view-fullscreen"
            onClicked: toogleFullscreen()
            checked: fullScreen
        }

        PixMenu
        {
            id: _picMenu
            index: viewer.currentIndex
            model: control.model
        }

        footBar.visible: !holder.visible && root.visibility !== Window.FullScreen
        autoHideFooter: true
        autoHideFooterMargins: control.height
        autoHideFooterDelay: 3000
        floatingFooter: !viewerSettings.previewBarVisible && !viewerSettings.tagBarVisible

        footBar.rightContent: [
            ToolButton
            {
                icon.name: "document-share"
                onClicked:
                {
                    Maui.Platform.shareFiles([control.currentPic.url])
                }
            }
        ]

        footBar.leftContent: ToolButton
        {
            icon.name: "draw-freehand"
            onClicked:
            {
//                    _doodleDialog.sourceItem = control.viewer.currentItem
//                    _doodleDialog.open()
                control.push(_editorComponent,({} ), StackView.Immediate)
            }
        }

        footBar.middleContent: Maui.ToolActions
        {
            expanded: true
            autoExclusive: false
            checkable: false

            Action
            {
                enabled: Maui.Platform.hasKeyboard
                text: i18n("Previous")
                icon.name: "go-previous"
                onTriggered: previous()
            }

            Action
            {
                text: i18n("Favorite")
                icon.name: "love"
                checked: control.currentPicFav
                onTriggered:
                {
                    if(control.currentPicFav)
                        tagBar.list.removeFromUrls("fav")
                    else
                        tagBar.list.insertToUrls("fav")

                    control.currentPicFav = !control.currentPicFav
                }
            }

            Action
            {
                enabled: Maui.Android.hasKeyboard
                icon.name: "go-next"
                onTriggered: next()
            }
        }

        Maui.Holder
        {
            id: holder
            visible: viewer.count === 0 /*|| viewer.currentItem.status !== Image.Ready*/

            emoji: "qrc:/assets/add-image.svg"
            isMask: true
            title : i18n("No Pics!")
            body: i18n("Open an image from your collection")
            emojiSize: Maui.Style.iconSizes.huge
        }

        ColumnLayout
        {
            height: parent.height
            width: parent.width
            spacing: 0

            Viewer
            {
                id: viewer
                visible: !holder.visible
                Layout.fillHeight: true
                Layout.fillWidth: true

//                TapHandler
//                {
//                    grabPermissions: PointerHandler.CanTakeOverFromAnything
//                    acceptedButtons: Qt.LeftButton | Qt.RightButton

//                    onSingleTapped:
//                    {
//                        galleryRollBg.toogle()
////                        root.headBar.visible = !root.headBar.visible
//                        viewer.forceActiveFocus()
//                    }
//                }

                Rectangle
                {
                    id: galleryRollBg
                    width: parent.width
                    anchors.bottom: parent.bottom
                    height: Math.min(100, Math.max(parent.height * 0.12, 60))
                    visible: viewerSettings.previewBarVisible && galleryRoll.rollList.count > 0 && opacity> 0
                    color: Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.7)
                    Behavior on opacity
                    {
                        NumberAnimation
                        {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    GalleryRoll
                    {
                        id: galleryRoll
                        height: parent.height -Maui.Style.space.small
                        width: parent.width
                        anchors.centerIn: parent
                        model: control.model
                        onPicClicked: view(index)
                    }

                    function toogle()
                    {
                        galleryRollBg.opacity = !galleryRollBg.opacity
                    }
                }
            }

            FB.TagsBar
            {
                id: tagBar
                visible: !holder.visible && viewerSettings.tagBarVisible && !fullScreen
                Layout.fillWidth: true
                allowEditMode: true
                list.urls: [currentPic.url]
                list.strict: false

                onAddClicked:
                {
                    dialogLoader.sourceComponent = tagsDialogComponent
                    dialog.composerList.urls = [currentPic.url]
                    dialog.open()
                }

                onTagRemovedClicked: list.removeFromUrls(index)
                onTagsEdited: list.updateToUrls(tags)

                Connections
                {
                    target: dialog
                    ignoreUnknownSignals: true
                    enabled: dialogLoader.sourceComponent === tagsDialogComponent
                    function onTagsReady()
                    {
                        tagBar.list.refresh()
                    }
                }
            }
        }
    }

    function next()
    {
        var index = control.currentPicIndex

        if(index < control.viewer.count-1)
            index++
        else
            index= 0

        view(index)
    }

    function previous()
    {
        var index = control.currentPicIndex

        if(index > 0)
            index--
        else
            index = control.viewer.count-1

        view(index)
    }

    function view(index)
    {
        if(control.viewer.count > 0 && index >= 0 && index < control.viewer.count)
        {
            control.currentPicIndex = index
            control.currentPic = control.model.get(control.currentPicIndex)

            control.currentPicFav = FB.Tagging.isFav(control.currentPic.url)
            root.title = control.currentPic.title
            control.roll.position(control.currentPicIndex)
        }
    }

}


