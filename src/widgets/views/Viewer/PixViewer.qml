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
import org.maui.pix 1.0 as Pix
import GalleryList 1.0

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
    property Maui.BaseModel currentModel : _defaultModel

    property bool tagBarVisible : Maui.FM.loadSettings("TAGBAR", "PIX", true) === "true" ? true : false
    property bool previewBarVisible: Maui.FM.loadSettings("PREVIEWBAR", "PIX", true) === "true" ? true : false
    property string viewerBackgroundColor : Maui.FM.loadSettings("VIEWER_BG_COLOR", "PIX", Kirigami.Theme.backgroundColor)
    property string viewerForegroundColor : Maui.FM.loadSettings("VIEWER_FG_COLOR", "PIX", Kirigami.Theme.textColor)

    padding: 0
    Kirigami.Theme.backgroundColor: viewerBackgroundColor


    //    EditTools
    //    {
    //        id: editTools
    //    }

    Maui.BaseModel
    {
        id: _defaultModel
        list: GalleryList {}
    }

    PixMenu
    {
        id: _picMenu
        index: viewer.currentIndex
         model: currentModel
    }

    headBar.visible: false

    footBar.rightContent: [

        ToolButton
        {
            icon.name: "document-share"
            onClicked:
            {
                if(isAndroid)
                    Maui.Android.shareDialog(control.currentPic.url)
                else
                {
                    dialogLoader.sourceComponent = shareDialogComponent
                    dialog.show([control.currentPic.url])
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
            onClicked:
            {
                if(pixViewer.currentPicFav)
                    tagBar.list.removeFromUrls("fav")
                else
                    tagBar.list.insertToUrls("fav")

                pixViewer.currentPicFav = !pixViewer.currentPicFav
            }
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
                emoji: viewer.count === 0 ? "qrc:/img/assets/add-image.svg" : "qrc:/img/assets/animat-image-color.gif"
                isMask: false
                isGif : viewer.currentItem.status !== Image.Ready
                title : viewer.count === 0 ? qsTr("No Pics!") : qsTr("Loading...")
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
                list.strict: false
                onTagClicked: PIX.searchFor(tag)
                onAddClicked:
                {
                    dialogLoader.sourceComponent = tagsDialogComponent
                    dialog.composerList.urls = [currentPic.url]
                    dialog.open()
                }

                onTagRemovedClicked: list.removeFromUrls(index)
                onTagsEdited: list.updateToUrls(tags)
            }

            Connections
            {
                target: dialog
                ignoreUnknownSignals: true
                enabled: dialogLoader.sourceComponent === tagsDialogComponent
                onTagsReady: tagBar.list.refresh()
            }
        }


        GalleryRoll
        {
            id: galleryRoll
            Layout.fillWidth: true
            Layout.margins: 0
            Layout.topMargin: Maui.Style.space.medium
            Layout.bottomMargin: Maui.Style.space.medium
            Layout.preferredHeight: 120
            visible: control.previewBarVisible && rollList.count > 0
            onPicClicked: VIEWER.view(index)
        }
    }

    function toogleTagbar()
    {
        control.tagBarVisible = !control.tagBarVisible
        Maui.FM.saveSettings("TAGBAR", tagBarVisible, "PIX")
    }

    function tooglePreviewBar()
    {
        control.previewBarVisible = !control.previewBarVisible
        Maui.FM.saveSettings("PREVIEWBAR", previewBarVisible, "PIX")
    }
}
