import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../widgets/views/Pix.js" as PIX
import "../../../db/Query.js" as Q

import org.kde.maui 1.0 as Maui

Maui.Page
{

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



    headBarTitle: currentPic.title || ""
    headBarExit: false
    headBarVisible: !holder.visible && !fullScreen
    headBar.rightContent: [

        Maui.ToolButton
        {
            iconName: "edit-rename"
            iconColor: editTools.visible ? highlightColor : textColor
            onClicked: editTools.visible ? editTools.close() : editTools.open()

        },

        Maui.ToolButton
        {
            iconName: "overflow-menu"
            onClicked: viewerMenu.popup()
        }
    ]

    headBar.leftContent: Maui.ToolButton
    {
        iconName: "document-save-as"
        onClicked: albumsDialog.show(currentPic.url)
    }

    footBar.margins: 0
    footBar.visible: !holder.visible && tagBarVisible && !fullScreen

    footBar.middleContent: Maui.TagsBar
    {
        id: tagBar
        width: footBar.width
        height: footBar.height

        allowEditMode: true
        onAddClicked: tagsDialog.show(currentPic.url)
        onTagRemovedClicked: if(pix.removePicTag(tagsList.model.get(index).tag, pixViewer.currentPic.url))
                                 tagsList.model.remove(index)
        onTagsEdited:
        {
            PIX.updatePicTags(tags, pixViewer.currentPic.url)
            VIEWER.setCurrentPicTags()
        }
    }

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

    Maui.Holder
    {
        id: holder
        message: "<h2>No Pic!</h2><p>Open an image from your collection</p>"
        emoji: "qrc:/img/assets/face-hug.png"
        visible: viewer.list.count === 0
        fgColor: viewerForegroundColor
    }

    EditTools
    {
        id: editTools
        height: parent.height - root.headBar.height - root.footBar.height - pixViewer.headBar.height
        y: isMobile ? pixViewer.headBar.height : pixViewer.headBar.height + root.footBar.height

    }

    //    Rectangle
    //    {
    //        id: shadow
    //        width: parent.width
    //        height: parent.height - headerBar.height
    //        y: headerBar.height
    //        color: textColor
    //        opacity: 0.6
    //        visible: shareDialog.opened
    //    }

    contentData: Viewer
    {
        id: viewer
        height: parent.height
        width: parent.width

        GalleryRoll
        {
            id: galleryRoll
            visible: !holder.visible
            anchors.bottom: parent.bottom
            onPicClicked: VIEWER.view(index)
        }
    }
}
