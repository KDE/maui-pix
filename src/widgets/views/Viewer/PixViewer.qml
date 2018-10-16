import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../widgets/views/Pix.js" as PIX
import "../../../db/Query.js" as Q
import "../.."

import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control
    property alias viewer : viewer
    property alias holder : holder
    property alias tagBar : tagBar
    property alias roll : galleryRoll

    property bool currentPicFav: false
    property var currentPic : ({})
    property int currentPicIndex : 0

    property bool tagBarVisible : pix.loadSettings("TAGBAR", "PIX", true) === "true" ? true : false
    property string viewerBackgroundColor : pix.loadSettings("VIEWER_BG_COLOR", "PIX", backgroundColor)
    property string viewerForegroundColor : pix.loadSettings("VIEWER_FG_COLOR", "PIX", textColor)

    margins: 0
    colorScheme.backgroundColor: viewerBackgroundColor
    headBarExit: false
    headBarTitle: currentPic.title ? currentPic.title : ""
    headBar.rightContent: [
        Maui.ToolButton
        {
            iconName: "document-save-as"
            onClicked: albumsDialog.open()
        },

        Maui.ToolButton
        {
            iconName: "object-rotate-left"
            onClicked: viewer.list.currentItem.rotateLeft()
        },

        Maui.ToolButton
        {
            iconName: "object-rotate-right"
            onClicked: viewer.list.currentItem.rotateRight()
        },

        Maui.ToolButton
        {
            iconName: "overflow-menu"
            onClicked: viewerMenu.popup()
        }
    ]

    headBar.leftContent: [
        Maui.ToolButton
        {
            iconName: "document-share"
            onClicked: isAndroid ? Maui.Android.shareDialog([pixViewer.currentPic.url]) :
                                   shareDialog.show([pixViewer.currentPic.url])
        },

        Maui.ToolButton
        {
            iconName: "view-preview"
            onClicked: control.contentIsRised ? dropContent() : riseContent()
            iconColor: control.contentIsRised ? colorScheme.highlightColor: colorScheme.textColor

        },

        Maui.ToolButton
        {
            iconName: "tag"
            onClicked: toogleTagbar()
            iconColor: tagBarVisible ? colorScheme.highlightColor: colorScheme.textColor
        }
    ]

    Connections
    {
        target: tagsDialog
        onPicTagged: if(currentView === views.viewer)
                         VIEWER.setCurrentPicTags()
    }

    ViewerMenu
    {
        id: viewerMenu
    }

    ConfigurationDialog
    {
        id : viewerConf
    }

    EditTools
    {
        id: editTools

    }


    backContain: GalleryRoll
    {
        id: galleryRoll
        visible: !holder.visible
        onPicClicked: VIEWER.view(index)
    }


    floatingBar: true
    footBarOverlap: true

    Viewer
    {
        id: viewer

        height: parent.height
        width: parent.width

        floatingBar: true
        headBarVisible: false

        footBar.colorScheme.backgroundColor: accentColor
        footBar.colorScheme.textColor: altColorText

        footBar.middleContent: [

            Maui.ToolButton
            {
                iconName: "go-previous"
                iconColor: altColorText
                onClicked: VIEWER.previous()
            },

            Maui.ToolButton
            {
                iconName: "love"
                colorScheme.highlightColor: "#ff557f";
                iconColor: pixViewer.currentPicFav ? colorScheme.highlightColor : colorScheme.textColor
                onClicked: pixViewer.currentPicFav = VIEWER.fav([pixViewer.currentPic.url])
            },

            Maui.ToolButton
            {
                iconName: "go-next"
                iconColor: altColorText
                onClicked: VIEWER.next()
            }
        ]


        Maui.Holder
        {
            id: holder
            emoji: "qrc:/img/assets/Rainbow.png"
            isMask: false
            title : "No Pic!"
            body: "Open an image from your collection"
            emojiSize: iconSizes.huge
            visible: viewer.list.count === 0
            fgColor: viewerForegroundColor
        }


        footer: Maui.TagsBar
        {
            id: tagBar
            visible: !holder.visible && tagBarVisible && !fullScreen
            Layout.fillWidth: true
            bgColor: viewerBackgroundColor
            allowEditMode: true
            onTagClicked: PIX.searchFor(tag)
            onAddClicked: tagsDialog.show(currentPic.url)
            onTagRemovedClicked: if(pix.removePicTag(tagsList.model.get(index).tag, pixViewer.currentPic.url))
                                     tagsList.model.remove(index)
            onTagsEdited:
            {
                PIX.updatePicTags(tags, pixViewer.currentPic.url)
                VIEWER.setCurrentPicTags()
            }
        }
    }

    function toogleTagbar()
    {
        tagBarVisible = !tagBarVisible
        pix.saveSettings("TAGBAR", tagBarVisible, "PIX")
    }
}
