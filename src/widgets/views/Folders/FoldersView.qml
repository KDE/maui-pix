import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.12 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.pix 1.0

import "../../../view_models"

StackView
{
    id: control

    property string currentFolder : ""
    property alias picsView : control.currentItem
    property Flickable flickable : picsView.flickable

    initialItem: Maui.GridView
    {
        id: foldersPage
        itemSize: Math.min(200, Math.max(120, control.width/3))
        itemHeight: 200

        margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.big

        holder.emoji: "qrc:/assets/view-preview.svg"
        holder.title : i18n("No Folders!")
        holder.body: i18n("Add new image sources")
        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.visible: foldersList.count === 0

        model: Maui.BaseModel
        {
            id: folderModel
            list: FoldersList
            {
                id: foldersList
                folders: _galleryView.list.folders
            }
            sortOrder: Qt.DescendingOrder
            sort: "modified"
            recursiveFilteringEnabled: false
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        delegate: CollageDelegate
        {
            id: _delegate
            property var folderPath : [model.path]

            height: foldersPage.cellHeight - Maui.Style.space.medium
            width: foldersPage.cellWidth - Maui.Style.space.medium
            isCurrentItem: GridView.isCurrentItem

            contentWidth: foldersPage.itemSize - 10
            contentHeight: foldersPage.cellHeight - 20

            list.urls: folderPath
            template.label1.text: model.label
            template.label3.text: Maui.FM.formatDate(model.modified, "dd/MM/yyyy")
            template.iconSource: model.icon

            onClicked:
            {
                foldersPage.currentIndex = index

                if(Maui.Handy.singleClick)
                {
                    control.push(picsViewComponent)
                    picsView.title = model.label
                    currentFolder = model.path
                    picsView.list.urls = [currentFolder]
                }
            }

            onDoubleClicked:
            {
                foldersPage.currentIndex = index

                if(!Maui.Handy.singleClick)
                {
                    control.push(picsViewComponent)
                    picsView.title = model.label
                    currentFolder = model.path
                    picsView.list.urls = [currentFolder]
                }
            }
        }
    }

    Component
    {
        id: picsViewComponent
        PixGrid
        {
            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name:"go-previous"
                onClicked: control.pop()
            }
            list.recursive: false

            holder.emoji: "qrc:/assets/add-image.svg"
            holder.title : i18n("Folder is empty!")
            holder.body: i18n("There's not images in this folder")
            holder.emojiSize: Maui.Style.iconSizes.huge
        }
    }

    function refresh()
    {
        foldersList.refresh()
    }
}
