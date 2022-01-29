import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.9 as Kirigami
import org.mauikit.controls 1.3 as Maui
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
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorGroup: Kirigami.Theme.View

        flickable: _foldersGrid.flickable

        headBar.middleContent: Maui.SearchField
        {
            Layout.fillWidth: true
            Layout.maximumWidth: 500
            Layout.alignment: Qt.AlignCenter

            placeholderText: i18np("Filter %1 folder", "Filter %1 folders", foldersList.count)
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
            holder.visible: foldersList.count === 0

            model: Maui.BaseModel
            {
                id: folderModel
                list: FoldersList
                {
                    id: foldersList
                    folders: mainGalleryList.folders
                }
                sortOrder: Qt.DescendingOrder
                sort: "modified"
                recursiveFilteringEnabled: false
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            delegate: Item
            {
                height: GridView.view.cellHeight - Maui.Style.space.tiny
                width: GridView.view.cellWidth

                Maui.CollageItem
                {
                    imageWidth: 120
                    imageHeight: 120

                    anchors.fill: parent
                    anchors.margins: Kirigami.Settings.isMobile ? Maui.Style.space.tiny : Maui.Style.space.medium

                    isCurrentItem: parent.GridView.isCurrentItem
                    template.labelSizeHint: 32
                    images: _galleryList.files
                    label1.text: model.label
                    label1.font.bold: true
                    label1.font.weight: Font.Bold

                    GalleryList
                    {
                        id: _galleryList
                        urls:  [model.path]
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
            holder.body: i18n("There're no images in this folder")
        }
    }

    function refresh()
    {
        foldersList.refresh()
    }
}
