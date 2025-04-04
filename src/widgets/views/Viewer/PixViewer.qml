// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick

import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.mauikit.imagetools as IT
import org.mauikit.imagetools.editor as ITEditor

import org.maui.pix as Pix

import "../../../view_models"

StackView
{
    id: control

    readonly property alias viewer : viewer
    readonly property alias holder : holder
    readonly property alias roll : galleryRoll
    readonly property bool editing : control.currentItem.objectName === "imageEditor"

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

    Component
    {
        id: _editorComponent

        ITEditor.ImageItem
        {

            image: _doc.image
            fillMode: Image.PreserveAspectFit

            ITEditor.ImageDocument
            {
                id: _doc
                path: control.currentPic.url
            }

            Row
            {
                anchors.centerIn: parent

                Slider
                {
                    id: _slider
                   from: -100
                   to: 100
                    value: _doc.brightness
                    live: false
                    stepSize: 1

                   onMoved: _doc.adjustBrightness(value)
                }

                Button
                {
                   text: "brightness at " + _doc.brightness

                   onClicked: _doc.adjustBrightness(60)
                }

                Button
                {
                   text: "brightness at " + _doc.brightness

                   onClicked: _doc.adjustBrightness(-87)
                }

                Button
                {
                   text: "brightness at " + _doc.brightness

                   onClicked: _doc.adjustBrightness(20)
                }

                Button
                {
                   text: "contrast at " + _doc.contrast

                   onClicked: _doc.adjustContrast(2.2)
                }


                Button
                {
                   text: "saturation at " + _doc.contrast

                   onClicked: _doc.adjustSaturation(150)
                }

                Button
                {
                    text: "undo" - "brightness at " + _doc.brightness
                    onClicked:
                    {
                        _doc.undo()
                        _slider.value =  _doc.brightness

                    }
                }

                Button
                {
                    text: "apply"
                    onClicked:
                    {
                        _doc.applyChanges()

                    }
                }
            }
        }
    }

    initialItem: Maui.Page
    {
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
            FB.FavButton
            {
                url: currentPic.url
            },

            ToolButton
            {
                icon.name: "document-share"
                onClicked:
                {
                    Maui.Platform.shareFiles([control.currentPic.url])
                }
            },

            ToolButton
            {
                icon.name: "draw-freehand"
                onClicked:
                {
                    control.push(_editorComponent)
                }
            },

            // Loader
            // {
            //     active: Maui.Handy.isLinux
            //     asynchronous: true
            //     sourceComponent: ToolButton
            //     {
            //         icon.name: "format-text-bold"
            //         checked: viewerSettings.enableOCR
            //         enabled: !viewer.isAnimated
            //         onClicked: viewerSettings.enableOCR = !viewerSettings.enableOCR
            //         // onClicked:
            //         // {
            //         //     var component = Qt.createComponent("qrc:/app/maui/pix/widgets/views/Viewer/OCRPage.qml")
            //         //     if (component.status == Component.Ready)
            //         //         var object = component.createObject()
            //         //     // else
            //         //     //     component.statusChanged.connect(finishCreation);

            //         //     control.push(object)
            //         // }

            //     }
            // },

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

                Rectangle
                {
                    id: galleryRollBg
                    width: parent.width
                    anchors.bottom: parent.bottom
                    height: Math.min(100, Math.max(parent.height * 0.12, 60))
                    visible: viewerSettings.previewBarVisible && galleryRoll.rollList.count > 1 && !viewer.imageZooming
                    color: Qt.rgba(Maui.Theme.backgroundColor.r, Maui.Theme.backgroundColor.g, Maui.Theme.backgroundColor.b, 0.7)

                    opacity: visible ? 1 : 0
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


