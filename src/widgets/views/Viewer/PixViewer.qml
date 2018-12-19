import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../widgets/views/Pix.js" as PIX
import "../../../db/Query.js" as Q
import "../.."

import org.kde.mauikit 1.0 as Maui
import PIX 1.0
import PixModel 1.0
import GalleryList 1.0

Maui.Page
{
    id: control

    property alias viewer : viewer
    property alias holder : holder
    property alias tagBar : tagBar
    property alias roll : galleryRoll
    property alias model : pixModel
    property alias list : pixModel.list

    property bool currentPicFav: false
    property var currentPic : ({})
    property int currentPicIndex : 0

    property bool tagBarVisible : Maui.FM.loadSettings("TAGBAR", "PIX", true) === "true" ? true : false
    property string viewerBackgroundColor : Maui.FM.loadSettings("VIEWER_BG_COLOR", "PIX", backgroundColor)
    property string viewerForegroundColor : Maui.FM.loadSettings("VIEWER_FG_COLOR", "PIX", textColor)

    margins: 0
    colorScheme.backgroundColor: viewerBackgroundColor
    headBarExit: false
    headBarTitle: currentPic.title ? currentPic.title : ""
    headBar.rightContent: [
        Maui.ToolButton
        {
            iconName: "document-save-as"
            onClicked:
            {
                dialogLoader.sourceComponent = albumsDialogComponent
                dialog.show()
            }
        },

        Maui.ToolButton
        {
            iconName: "object-rotate-left"
            onClicked: viewer.currentItem.rotateLeft()
        },

        Maui.ToolButton
        {
            iconName: "object-rotate-right"
            onClicked: viewer.currentItem.rotateRight()
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
            onClicked:
            {
                if(isAndroid)
                Maui.Android.shareDialog([pixViewer.currentPic.url])
                else
                {
                    dialogLoader.sourceComponent = shareDialogComponent
                    dialog.show([pixViewer.currentPic.url])
                }
            }
        },

        Maui.ToolButton
        {
            iconName: "image-preview"
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

    //    Connections
    //    {
    //        target: tagsDialog
    //        onPicTagged: if(currentView === views.viewer)
    //                         VIEWER.setCurrentPicTags()
    //    }

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

    PixMenu
    {
        id: _picMenu
        index: viewer.currentIndex
    }

    PixModel
    {
        id: pixModel
    }

    Viewer
    {
        id: viewer

        height: parent.height
        width: parent.width

        floatingBar: true
        headBar.visible: false

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
            emoji: viewer.count === 0 ? "qrc:/img/assets/Rainbow.png" : "qrc:/img/assets/animat-image-color.gif"
            isMask: false
            isGif : viewer.currentItem.status !== Image.Ready
            title : viewer.count === 0 ? qsTr("No Pic!") : qsTr("Loading...")
            body: viewer.count === 0 ? qsTr("Open an image from your collection") : qsTr("Your pic is almost ready")
            emojiSize: isGif ? iconSizes.enormous : iconSizes.huge
            visible: viewer.count === 0 || viewer.currentItem.status !== Image.Ready
            colorScheme.backgroundColor: viewerForegroundColor
        }

        footer: Maui.TagsBar
        {
            id: tagBar
            visible: !holder.visible && tagBarVisible && !fullScreen
            Layout.fillWidth: true
            bgColor: viewerBackgroundColor
            allowEditMode: true
            list.urls: [currentPic.url]
            onTagClicked: PIX.searchFor(tag)
            onAddClicked:
            {
                dialogLoader.sourceComponent = tagsDialogComponent
                dialog.show(currentPic.url)
            }

            onTagRemovedClicked: list.removeFromUrls(index)
            onTagsEdited: list.updateToUrls(tags)
        }
    }

    function toogleTagbar()
    {
        tagBarVisible = !tagBarVisible
        Maui.FM.saveSettings("TAGBAR", tagBarVisible, "PIX")
    }
}
