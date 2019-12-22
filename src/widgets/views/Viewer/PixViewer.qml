import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../widgets/views/Pix.js" as PIX
import "../../../db/Query.js" as Q
import "../.."
import org.kde.kirigami 2.7 as Kirigami

import org.kde.mauikit 1.0 as Maui
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
    property string viewerBackgroundColor : Maui.FM.loadSettings("VIEWER_BG_COLOR", "PIX", Kirigami.Theme.backgroundColor)
    property string viewerForegroundColor : Maui.FM.loadSettings("VIEWER_FG_COLOR", "PIX", Kirigami.Theme.textColor)

    padding: 0
    Kirigami.Theme.backgroundColor: viewerBackgroundColor


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

    //    EditTools
    //    {
    //        id: editTools
    //    }

    PixMenu
    {
        id: _picMenu
        index: viewer.currentIndex
    }

    Maui.BaseModel
    {
        id: pixModel
        list: GalleryList {}
    }

    headBar.visible: false

    footBar.rightContent: [

        ToolButton
        {
            icon.name: "document-share"
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

        ToolButton
        {
            icon.name: "object-rotate-left"
            onClicked: viewer.currentItem.rotateLeft()
        },

        ToolButton
        {
            icon.name: "object-rotate-right"
            onClicked: viewer.currentItem.rotateRight()
        },

        ToolButton
        {
            icon.name: "overflow-menu"
            onClicked: viewerMenu.popup()
        }
    ]



//    footBar.colorScheme.backgroundColor: accentColor
//    footBar.colorScheme.textColor: altColorText
    //        footBar.colorScheme.borderColor: accentColor

    footBar.leftContent: [

        ToolButton
        {
            icon.name: "go-previous"
//            icon.color: altColorText
            onClicked: VIEWER.previous()
        },

        ToolButton
        {
            Kirigami.Theme.inherit: false
            Kirigami.Theme.highlightColor: "#ff5a86"
            icon.name: "love"
//            colorScheme.highlightColor: "#ff557f";
            checked: pixViewer.currentPicFav
            icon.color: pixViewer.currentPicFav ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            onClicked: pixViewer.currentPicFav = VIEWER.fav([pixViewer.currentPic.url])
        },

        ToolButton
        {
            icon.name: "go-next"
//            icon.color: altColorText
            onClicked: VIEWER.next()
        }
    ]

    ColumnLayout
    {
        height: parent.height
        width: parent.width

        Viewer
        {
            id: viewer
            Layout.fillHeight: true
            Layout.fillWidth: true

            Maui.Holder
            {
                id: holder
                emoji: viewer.count === 0 ? "qrc:/img/assets/Rainbow.png" : "qrc:/img/assets/animat-image-color.gif"
                isMask: false
                isGif : viewer.currentItem.status !== Image.Ready
                title : viewer.count === 0 ? qsTr("No Pic!") : qsTr("Loading...")
                body: viewer.count === 0 ? qsTr("Open an image from your collection") : qsTr("Your pic is almost ready")
                emojiSize: isGif ? Maui.Style.iconSizes.enormous : Maui.Style.iconSizes.huge
                visible: viewer.count === 0 /*|| viewer.currentItem.status !== Image.Ready*/
                Kirigami.Theme.backgroundColor: viewerForegroundColor
            }

            footer: Maui.TagsBar
            {
                id: tagBar
                visible: !holder.visible && tagBarVisible && !fullScreen
                Layout.fillWidth: true
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


        GalleryRoll
        {
            id: galleryRoll
            Layout.fillWidth: true
            Layout.margins: 0
            Layout.topMargin: Maui.Style.space.medium
            Layout.bottomMargin: Maui.Style.space.medium
            rollHeight: 120 * unit
            visible: false
            onPicClicked: VIEWER.view(index)
        }
    }


    function toogleTagbar()
    {
        tagBarVisible = !tagBarVisible
        Maui.FM.saveSettings("TAGBAR", tagBarVisible, "PIX")
    }
}
