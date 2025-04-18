// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick

import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.mauikit.imagetools as IT

import org.maui.pix as Pix

import "../../../view_models"


Maui.Page
{
    id: control

    readonly property alias viewer : viewer
    readonly property alias holder : holder
    readonly property alias roll : galleryRoll

    readonly property alias model : viewer.model

    property bool currentPicFav: false
    property var currentPic : ({})
    property int currentPicIndex : 0
    property bool doodle : false

    PixMenu
    {
        id: _picMenu

        index: control.currentPicIndex
        model: viewer.model
    }

    padding: 0
    title: currentPic.title
    showTitle: root.isWide
    altHeader: Maui.Handy.isMobile
    floatingHeader: true
    autoHideHeader: viewer.imageZooming
    Maui.Controls.showCSD: control.Maui.Controls.showCSD
    headBar.visible: true

    onGoBackTriggered: _stackView.pop()

    headBar.farLeftContent: [
        ToolButton
        {
            icon.name: "go-previous"
            text: i18n("Gallery")
            display: ToolButton.TextBesideIcon
            onClicked: toggleViewer()
        },

        Loader
        {
            active: !holder.visible && (!Maui.Handy.isMobile) && control.viewer.count > 1 //only show footbar control for desktop mode
            asynchronous: true
            sourceComponent:  Maui.ToolActions
            {

                expanded: true
                autoExclusive: false
                checkable: false
                display: ToolButton.IconOnly

                Action
                {
                    text: i18n("Previous")
                    icon.name: "go-previous"
                    onTriggered: previous()
                }

                Action
                {
                    icon.name: "go-next"
                    onTriggered: next()
                }
            }
        }
    ]

    headBar.rightContent: [     

        ToolButton
        {
            icon.name: "view-fullscreen"
            onClicked: toogleFullscreen()
            checked: fullScreen
        },

        Loader
        {
            asynchronous: true
            sourceComponent: _mainMenuComponent
        }
    ]

    Maui.Holder
    {
        id: holder
        visible: viewer.count === 0 /*|| viewer.currentItem.status !== Image.Ready*/
        anchors.fill: parent
        emoji: "qrc:/assets/add-image.svg"
        isMask: true
        title : i18n("No Pics!")
        body: i18n("Open an image from your collection")
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



            Loader
            {
                id: _actionsBarLoader
                // active: settings.showActionsBar
                visible: status == Loader.Ready
                asynchronous: true

                anchors.bottom: galleryRollBg.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Maui.Style.space.big

                sourceComponent: Pane
                {
                    id: _pane
                    Maui.Theme.colorSet: Maui.Theme.Complementary
                    Maui.Theme.inherit: false

                    background: Rectangle
                    {
                        radius: Maui.Style.radiusV
                        color: Maui.Theme.alternateBackgroundColor

                        layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
                        layer.effect: MultiEffect
                        {
                            autoPaddingEnabled: true
                            shadowEnabled: true
                            shadowColor: "#000000"
                        }
                    }

                    ScaleAnimator on scale
                    {
                        from: 0
                        to: 1
                        duration: Maui.Style.units.longDuration
                        running: visible
                        easing.type: Easing.OutInQuad
                    }

                    OpacityAnimator on opacity
                    {
                        from: 0
                        to: 1
                        duration: Maui.Style.units.longDuration
                        running: visible
                    }

                    contentItem:  Row
                    {
                        spacing: Maui.Style.defaultSpacing

                        FB.FavButton
                        {
                            url: currentPic.url
                            flat: false
                        }

                        ToolButton
                        {
                            icon.name: "document-share"
                            flat: false
                            onClicked:
                            {
                                Maui.Platform.shareFiles([control.currentPic.url])
                            }
                        }

                        ToolButton
                        {
                            icon.name: "draw-freehand"
                            flat: false
                            onClicked:
                            {
                                openEditor(control.currentPic.url)
                            }
                        }
                    }
                }
            }

            Item
            {
                id: galleryRollBg
                width: parent.width
                clip: true

                y: !viewer.imageZooming ? parent.height - height : parent.height
                Behavior on y
                {
                    NumberAnimation
                    {
                        duration: Maui.Style.units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                height: visible ? Math.min(60, Math.max(parent.height * 0.12, 60)) : 0
                visible: viewerSettings.previewBarVisible && galleryRoll.rollList.count > 1

                Behavior on opacity
                {
                    NumberAnimation
                    {
                        duration: Maui.Style.units.longDuration
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
                    onPicClicked: (index) => view(index)
                }
            }
        }

        Loader
        {
            asynchronous: true
            active: !holder.visible && viewerSettings.tagBarVisible && !fullScreen
            Layout.fillWidth: true

            sourceComponent: FB.TagsBar
            {
                allowEditMode: true
                list.urls: [currentPic.url]
                list.strict: false

                onTagRemovedClicked: (index) => list.removeFromUrls(index)
                onTagsEdited: (tags) => list.updateToUrls(tags)
                onTagClicked: (tag) => openFolder("tags:///"+tag)
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
        // if(control.viewer.count > 0 && index >= 0 && index < control.viewer.count)
        {
            control.currentPicIndex = index
            control.currentPic = control.model.get(control.currentPicIndex)

            control.currentPicFav = FB.Tagging.isFav(control.currentPic.url)
            root.title = control.currentPic.title
            control.roll.position(control.currentPicIndex)
        }
    }
}


