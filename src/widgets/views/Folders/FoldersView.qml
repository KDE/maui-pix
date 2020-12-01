import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.3 as Maui
import org.maui.pix 1.0

import "../../../view_models"

StackView
{
    id: control

    property string currentFolder : ""
    property alias picsView : control.currentItem
    property Flickable flickable : picsView.flickable

    initialItem: Maui.Page
    {
        id: _foldersPage
        flickable: _foldersGrid.flickable

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            Layout.maximumWidth: 500
            placeholderText: i18n("Filter")
            onAccepted: folderModel.filter = text
            onCleared: folderModel.filter = ""
        }

        Maui.GridView
        {
            id: _foldersGrid
            anchors.fill: parent
            itemSize: Math.min(200, Math.max(100, Math.floor(width* 0.3)))
            itemHeight: itemSize + Maui.Style.rowHeight

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

            delegate: Maui.CollageItem
            {
                id: _delegate
                readonly property var folderPath : [model.path]

                height: _foldersGrid.cellHeight - Maui.Style.space.tiny
                width: _foldersGrid.cellWidth
                isCurrentItem: GridView.isCurrentItem

                contentWidth: _foldersGrid.itemSize - 10
                contentHeight: _foldersGrid.cellHeight - 20

                images: _galleryList.files
                template.label1.text: model.label
                template.label3.text: Maui.FM.formatDate(model.modified, "dd/MM/yyyy")
                template.iconSource: model.icon

                GalleryList
                {
                    id: _galleryList
                    urls: folderPath
                    autoReload: false
                    recursive: false
                    limit: 4
                }

                onClicked:
                {
                    _foldersGrid.currentIndex = index

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
                    _foldersGrid.currentIndex = index

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
