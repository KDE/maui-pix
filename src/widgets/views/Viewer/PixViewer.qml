import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../widgets/views/Pix.js" as PIX
import "../../../db/Query.js" as Q
import "../../../widgets/custom/TagBar"

PixPage
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


    Rectangle
    {
        anchors.fill: parent
        z: -1
        color: viewerBackgroundColor
    }

    headerbarTitle: currentPic.title || ""
    headerbarExit: false
    headerbarVisible: !holder.visible
    headerBarRight: [

        PixButton
        {
            iconName: "edit-rename"
            iconColor: editTools.visible ? pixColor : textColor
            onClicked: editTools.visible ? editTools.close() : editTools.open()

        },

        PixButton
        {
            iconName: "overflow-menu"
            onClicked: viewerMenu.popup()
        }

    ]

    headerBarLeft: [

        PixButton
        {
            iconName: "document-save-as"
            onClicked: albumsDialog.show(currentPic.url)
        }
    ]

    footer: ToolBar
    {
        id: footerToolbar
        position: ToolBar.Footer
        visible: !holder.visible && tagBarVisible
        TagBar
        {
            id: tagBar
            allowEditMode: true
            visible: parent.visible
            anchors.fill: parent
            onAddClicked: tagsDialog.show(currentPic.url)
            onTagRemovedClicked: if(pix.removePicTag(tagsList.model.get(index).tag, pixViewer.currentPic.url))
                                     tagsList.model.remove(index)
            onTagsEdited:
            {
                PIX.updatePicTags(tags, pixViewer.currentPic.url)
                tagsList.populate(Q.Query.picTags_.arg(pixViewer.currentPic.url))
            }
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

    PixHolder
    {
        id: holder
        message: "<h2>No Pic!</h2><p>Open an image from your collection</p>"
        emoji: "qrc:/img/assets/face-hug.png"
        visible: viewer.list.count === 0
        foregroundColor: viewerForegroundColor
    }

    EditTools
    {
        id: editTools
        width: parent.width * 0.4

        height: parent.height - headerBar.height - pixFooter.height - toolBar.height
        y: headerBar.height + pixFooter.height

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

    content: Viewer
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
