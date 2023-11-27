import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

import org.mauikit.filebrowsing 1.3 as FB

import org.maui.pix 1.0

import "../../../view_models"
import "../.."
import"../Gallery"

StackView
{
    id: control

    readonly property string currentFolder : currentItem.currentFolder
    readonly property alias picsView : control.currentItem
    readonly property Flickable flickable : picsView.flickable

    Component.onCompleted:
    {
        if(_collectionViewComponent.pendingFolder.length > 0)
        {
            openFolder(_collectionViewComponent.pendingFolder)
        }
    }

    initialItem: Maui.Page
    {
        id: _foldersPage
        readonly property string currentFolder : "folders:///"

        Maui.Theme.inherit: false
        Maui.Theme.colorGroup: Maui.Theme.View

        flickable: _foldersGrid.flickable
        headBar.visible: false

        property Component searchFieldComponent : Maui.SearchField
        {
            placeholderText: i18np("Filter %1 folder", "Filter %1 folders", foldersList.count)
            onAccepted:
            {
                folderModel.filters = text.split(",")
            }

            onCleared: folderModel.clearFilters()
        }

        StackView.onDeactivated:
        {
            folderModel.clearFilters()
        }

        Maui.GridBrowser
        {
            id: _foldersGrid
            anchors.fill: parent
            itemSize: Math.min(260, Math.max(140, Math.floor(availableWidth* 0.3)))
            itemHeight: itemSize + Maui.Style.rowHeight
            currentIndex: -1

            holder.emoji: "qrc:/assets/view-preview.svg"
            holder.title : foldersList.count === 0 ?
                               i18n("No Folders!") : i18n("Nothing Here!")
            holder.body: foldersList.count === 0 ? i18n("Add new image sources.") : i18n("Try something different.")
            holder.visible: _foldersGrid.count === 0

            onKeyPress: (event) =>
            {
                if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                {
                    openFolder(_foldersGrid.currentItem.path)
                }
            }

            model: Maui.BaseModel
            {
                id: folderModel
                list: FoldersList
                {
                    id: foldersList
                    folders: Collection.allImagesModel.folders
                }

                sortOrder: Qt.DescendingOrder
                sort: "modified"
                recursiveFilteringEnabled: false
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            delegate: Item
            {
                readonly property string path : model.path
                height: GridView.view.cellHeight
                width: GridView.view.cellWidth

                Maui.CollageItem
                {
                    imageWidth: 120
                    imageHeight: 120

                    anchors.fill: parent
                    anchors.margins: !root.isWide ? Maui.Style.space.tiny : Maui.Style.space.big

                    isCurrentItem: parent.GridView.isCurrentItem
                    images: model.preview.split(",")

                    tooltipText: model.path
                    label1.text: model.label
                    label2.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")

                    draggable: true

                    Drag.keys: ["text/uri-list"]
                    Drag.mimeData: Drag.active ? { "text/uri-list": model.path } : {}

                onClicked:
                {
                    _foldersGrid.currentIndex = index

                    if(Maui.Handy.singleClick)
                    {
                        openFolder(model.path)
                    }
                }

                onDoubleClicked:
                {
                    _foldersGrid.currentIndex = index

                    if(!Maui.Handy.singleClick)
                    {
                        openFolder(model.path)
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
        id: _picsView
        property string currentFolder
        readonly property var folderInfo : FB.FM.getFileInfo(currentFolder)

        headBar.visible: false
        title: control.folderInfo.label

        list.recursive: false
        list.urls: [currentFolder]
        list.activeGeolocationTags: browserSettings.gpsTags

        holder.emoji: "qrc:/assets/add-image.svg"
        holder.title : i18n("Folder is empty!")
        holder.body: i18n("There're no images in this folder")

        Keys.enabled: true
        Keys.onEscapePressed: control.pop()

        gridView.header: Column
        {
            width: parent.width
            spacing: Maui.Style.space.medium

            Maui.SectionHeader
            {
                width: parent.width
                label1.text: folderInfo.label
                label2.text: folderInfo.url ? (folderInfo.url).replace(FB.FM.homePath(), "") : ""
                template.label3.text: i18np("No images.", "%1 images", _picsView.gridView.count)
                template.label4.text: Qt.formatDateTime(new Date(folderInfo.modified), "d MMM yyyy")
                template.iconSource: folderInfo.icon

                template.content: ToolButton
                {
                    icon.name: "folder-open"
                    onClicked: Qt.openUrlExternally(currentFolder)
                }
            }

            Flow
            {
                spacing: Maui.Style.space.medium
                width: parent.width
                Repeater
                {
                    model: Maui.BaseModel
                    {
                        list: CitiesList
                        {
                            cities:  _picsView.list.cities
                        }
                    }

                    delegate: Maui.Chip
                    {
                        text: model.name
                        iconSource: "gps"
                        checked:  _picsView.model.filters.indexOf(model.id) === 0
                        checkable: true
                        onClicked:
                        {
                            if( _picsView.model.filters.indexOf(model.id) === 0)
                            {
                                _picsView.model.clearFilters()
                            }else
                            {
                                _picsView.model.filters = [model.id]
                            }
                        }

                    }
                }
            }
        }
    }
}

Component
{
    id: _allPicsComponent

    GalleryView
    {
        property string currentFolder : "collection:///"
        headBar.visible: false

        list: Collection.allImagesModel
    }
}

function refresh()
{
    foldersList.refresh()
}

function openFolder(url, filters)
{
    if(currentFolder === url)
        return;

    if(control.depth === 1)
    {
        if(url.startsWith("collection:///"))
        {
            control.push(_allPicsComponent, ({'currentFolder': url}))
        }else
        {
            control.push(picsViewComponent, ({'currentFolder': url}))
        }
    }else
    {
        if(currentFolder.startsWith("collection:///"))
        {
            if(url.startsWith("collection:///"))
            {
                control.currentItem.currentFolder = url
            }else
            {
                control.pop()
                control.push(picsViewComponent, ({'currentFolder': url}))
            }
        }else
        {
            if(url.startsWith("collection:///"))
            {
                control.pop()
                control.push(_allPicsComponent, ({'currentFolder': url}))
            }else
            {
                control.currentItem.currentFolder = url
            }
        }
    }

    control.currentItem.model.clearFilters()
    control.currentItem.model.filters = filters
}
}
