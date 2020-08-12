// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import "../../../view_models"
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../widgets/views/Pix.js" as PIX
import "../.."

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.pix 1.0 as Pix
import GalleryList 1.0

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
    property bool tagBarVisible : Maui.FM.loadSettings("TAGBAR", "PIX", true) === "true" ? true : false
    property bool previewBarVisible: Maui.FM.loadSettings("PREVIEWBAR", "PIX", true) === "true" ? true : false
    property bool doodle : false

    Component
    {
        id: _editorComponent
        Editor
        {
            objectName: "imageEditor"
            url: control.currentPic.url
        }
    }

    initialItem: Maui.Page
    {
        id: _viewer
        padding: 0
        Kirigami.Theme.colorSet: Kirigami.Theme.View

        PixMenu
        {
            id: _picMenu
            index: viewer.currentIndex
            model: control.model
        }


        footBar.visible: !holder.visible
        autoHideFooter: true
        autoHideFooterMargins: control.height
        autoHideFooterDelay: 3000
        floatingFooter: !previewBarVisible && !tagBarVisible

        footBar.rightContent: [
            ToolButton
            {
                icon.name: "draw-freehand"
                onClicked:
                {
//                    _doodleDialog.sourceItem = control.viewer.currentItem
//                    _doodleDialog.open()
                    control.push(_editorComponent,({} ), StackView.Immediate)
                }
            },

            ToolButton
            {
                icon.name: "document-share"
                onClicked:
                {
                    dialogLoader.sourceComponent = shareDialogComponent
                    dialog.urls = [control.currentPic.url]
                    dialog.open()
                }
            }
        ]

        footBar.leftContent: ToolButton
        {
            visible: !Kirigami.Settings.isMobile
            icon.name: "view-fullscreen"
            onClicked: control.toogleFullscreen()
            checked: fullScreen
        }

        footBar.middleContent: Maui.ToolActions
        {
            expanded: true
            autoExclusive: false
            checkable: false

            Action
            {
                text: i18n("Previous")
                icon.name: "go-previous"
                onTriggered: VIEWER.previous()
            }

            Action
            {
                text: i18n("Favorite")

                icon.name: "love"
                checked: pixViewer.currentPicFav
                onTriggered:
                {
                    if(pixViewer.currentPicFav)
                        tagBar.list.removeFromUrls("fav")
                    else
                        tagBar.list.insertToUrls("fav")

                    pixViewer.currentPicFav = !pixViewer.currentPicFav
                }
            }

            Action
            {
                icon.name: "go-next"
                onTriggered: VIEWER.next()
            }
        }

        Maui.Holder
        {
            id: holder
            visible: viewer.count === 0 /*|| viewer.currentItem.status !== Image.Ready*/

            emoji: viewer.count === 0 ? "qrc:/assets/add-image.svg" : "qrc:/assets/animat-image-color.gif"
            isMask: true
            isGif : viewer.currentItem.status !== Image.Ready
            title : viewer.count === 0 ? i18n("No Pics!") : i18n("Loading...")
            body: viewer.count === 0 ? i18n("Open an image from your collection") : i18n("Your pic is almost ready")
            emojiSize: isGif ? Maui.Style.iconSizes.enormous : Maui.Style.iconSizes.huge
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

                MouseArea
                {
                    width: parent.width
                    height: parent.height * 0.3
                    anchors.bottom: parent.bottom
                    propagateComposedEvents: true

                    onPressed:
                    {
                        galleryRollBg.toogle()
                        root.headBar.visible = !root.headBar.visible
                        control.footBar.visible = !control.footBar.visible
                        viewer.forceActiveFocus()
                        mouse.accepted = false
                    }

                    onReleased:
                    {
                        mouse.accepted = false
                    }
                }

                Rectangle
                {
                    id: galleryRollBg
                    width: parent.width
                    anchors.bottom: parent.bottom
                    height: Math.min(100, Math.max(parent.height * 0.12, 60))
                    visible: control.previewBarVisible && galleryRoll.rollList.count > 0 && opacity> 0
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
                        onPicClicked: VIEWER.view(index)
                    }

                    function toogle()
                    {
                        galleryRollBg.opacity = !galleryRollBg.opacity
                    }
                }
            }

            Maui.TagsBar
            {
                id: tagBar
                visible: !holder.visible && tagBarVisible && !fullScreen
                Layout.fillWidth: true
                position: ToolBar.Footer
                allowEditMode: true
                list.urls: [currentPic.url]
                list.strict: false
//                onTagClicked: PIX.searchFor(tag)
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
                    onTagsReady: tagBar.list.refresh()
                }
            }
        }

    }


    function toogleTagbar()
    {
        control.tagBarVisible = !control.tagBarVisible
        Maui.FM.saveSettings("TAGBAR", tagBarVisible, "PIX")
    }

    function tooglePreviewBar()
    {
        control.previewBarVisible = !control.previewBarVisible
        Maui.FM.saveSettings("PREVIEWBAR", previewBarVisible, "PIX")
    }

    function toogleFullscreen()
    {
        if(Window.window.visibility === Window.FullScreen)
        {
            Window.window.showNormal()
        }else
        {
            Window.window.showFullScreen()
        }

    }

}


