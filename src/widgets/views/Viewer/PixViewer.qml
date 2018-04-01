import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../widgets/custom/TagBar"
import "../../dialogs/share"
import "../../dialogs/Tags"

PixPage
{

    property alias viewer : viewer
    property alias holder : holder
    property alias tagBar : tagBar

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
            iconName: "draw-text"
        }
    ]

    footer: ToolBar
    {
        position: ToolBar.Footer

        TagBar
        {
            id: tagBar
            anchors.fill: parent
        }
    }

    TagsDialog
    {
        id: tagsDialog

        onPicTagged: tagBar.tagsList.model.append({"tag": tag})
    }

    PixHolder
    {
        id: holder
        message: "<h2>No Pic!</h2><p>Select or open an image from yuor gallery</p>"
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
    }

}
