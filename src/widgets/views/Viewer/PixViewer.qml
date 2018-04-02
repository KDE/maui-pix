import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../widgets/custom/TagBar"
import "../../dialogs/share"
import "../../dialogs/Tags"
import "../../dialogs/Albums"

PixPage
{

    property alias viewer : viewer
    property alias holder : holder
    property alias tagBar : tagBar
    property alias roll : galleryRoll

    property bool currentPicFav: false
    property var currentPic : ({})
    property var picContext : []
    property int currentPicIndex : 0

    headerbarTitle: currentPic.title || ""
    headerbarExit: false
    headerbarVisible: !holder.visible
    headerBarRight: [

        PixButton
        {
            iconName: "edit-rename"

        },

        PixButton
        {
            iconName: "overflow-menu"
        }

    ]

    headerBarLeft: [

        PixButton
        {
            iconName: "document-save-as"
            onClicked:
            {
                albumsDialog.picUrl = currentPic.url
                albumsDialog.open()
            }
        }
    ]

    footer: ToolBar
    {
        position: ToolBar.Footer
        visible: !holder.visible
        TagBar
        {
            id: tagBar
            anchors.fill: parent
            onAddClicked:
            {
                tagsDialog.url = currentPic.url
                tagsDialog.open()
            }
            onTagRemovedClicked: if(pix.removePicTag(tagsList.model.get(index).tag, pixViewer.currentPic.url))
                              tagsList.model.remove(index)
        }
    }

    TagsDialog
    {
        id: tagsDialog
        forAlbum: false
        onTagsAdded: addTagsToPic(url, tags)
        onPicTagged: tagBar.tagsList.model.insert(0, {"tag": tag})
    }

    AlbumsDialog
    {
        id: albumsDialog
    }

    PixHolder
    {
        id: holder
        message: "<h2>No Pic!</h2><p>Open an image from your collection</p>"
        emoji: "qrc:/img/assets/face-hug.png"
        visible: Object.keys(currentPic).length === 0
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

        GalleryRoll
        {
            id: galleryRoll
            anchors.bottom: parent.bottom
            onPicClicked: VIEWER.view(index)
        }

    }
}
