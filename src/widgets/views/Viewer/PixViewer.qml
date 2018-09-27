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
    headBarVisible: false

    background: Rectangle
    {
        color: viewerBackgroundColor
    }

   Rectangle
   {
       height: toolBarHeightAlt
       width: parent.width *0.7
       color: altColor
       radius: unit* 4
       visible: isMobile
       opacity: 0.7
       z: 999
       anchors
       {
           top: parent.top
           horizontalCenter: parent.horizontalCenter
           margins: space.big
       }

       Label
       {
           height: parent.height
           width: parent.width
           horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
           color: altColorText
           elide: Text.ElideRight
           text: currentPic.title
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

    EditTools
    {
        id: editTools

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

    ColumnLayout
    {
        spacing: 0
        height: parent.height
        width: parent.width

        Viewer
        {
            id: viewer
            Layout.fillHeight: true
            Layout.fillWidth: true

            floatingBar: true
            headBarVisible: false

            footBar.colorScheme.backgroundColor: accentColor
            footBar.colorScheme.textColor: altColorText

            footBar.leftContent: Maui.ToolButton
            {
                iconName: "document-share"
                iconColor: altColorText

                onClicked: isAndroid ? Maui.Android.shareDialog(pixViewer.currentPic.url) :
                                       shareDialog.show(pixViewer.currentPic.url)
            }

            footBar.middleContent: PixFooter
            {
                id: pixFooter
            }

        //    footBar.rightContent : Maui.ToolButton
        //    {
        //        iconName: fullScreen? "window-close" : "view-fullscreen"
        //        iconColor: altColorText

        //        onClicked: fullScreen = !fullScreen

        //    }

            footBar.rightContent : Maui.ToolButton
            {
                iconName: "document-save-as"
                iconColor: altColorText
                onClicked: editTools.visible ? editTools.close() : editTools.open()
            }


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

            GalleryRoll
            {
                id: galleryRoll
                visible: !holder.visible
                anchors.bottom: parent.bottom
                onPicClicked: VIEWER.view(index)
            }
        }

        Maui.TagsBar
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
}
