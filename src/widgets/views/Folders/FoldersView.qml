import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

import org.mauikit.filebrowsing as FB

import org.maui.pix

import "../../../view_models"
import "../.."
import"../Gallery"

StackView
{
    id: control
    objectName: "FoldersView"

    Keys.enabled: true
    Keys.forwardTo: currentItem
    Keys.onPressed: (event) =>
                    {
                        if(event.key === Qt.Key_Escape)
                        {
                            if(selectionBox.visible)
                            {
                                selectionBox.clear()
                            }else
                            {
                                control.pop()
                            }
                            event.accepted = true
                        }

                        if(event.key == Qt.Key_F && (event.modifiers & Qt.ControlModifier))
                        {
                            focusSearchField()
                            event.accepted = true
                        }
                    }

    readonly property string currentFolder : currentItem.currentFolder
    readonly property alias picsView : control.currentItem
    readonly property Flickable flickable : picsView.flickable

    readonly property string pendingFolder : initModule === "folder" ? initData[0] : ""
    Component.onCompleted:
    {
        if(pendingFolder.length > 0)
        {
            console.log("PENDING FOLDER TO BROWSE", pendingFolder)
            openFolder(pendingFolder)
        }
    }

    initialItem: Maui.Page
    {
        id: _foldersPage
        readonly property string currentFolder : "collection:///"

        Maui.Theme.inherit: false
        Maui.Theme.colorGroup: Maui.Theme.View
        flickable: _foldersGrid.flickable
        headBar.visible: false

        property Component extraOptions : ToolButton
        {
            text: i18n("New Folder")
            onClicked:  _foldersPage.headBar.Maui.Theme.printColorTable()
        }

        property Component searchFieldComponent : Maui.SearchField
        {
            id: _searchField
            placeholderText: i18np("Filter %1 folder", "Filter %1 folders", foldersList.count)
            onAccepted:
            {
                folderModel.filters = text.split(",")
                _foldersGrid.forceActiveFocus()
            }

            onCleared: folderModel.clearFilters()

            Keys.enabled: true
            Keys.onEscapePressed: _foldersGrid.forceActiveFocus()
        }

        Keys.enabled: true
        Keys.forwardTo: _foldersGrid

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
            flickable.reuseItems: true

            padding: 0

            holder.emoji: "qrc:/assets/view-preview.svg"
            holder.title : foldersList.count === 0 ?
                               i18n("No Folders!") : i18n("Nothing Here!")
            holder.body: foldersList.count === 0 ? i18n("Add new image sources.") : i18n("Try something different.")
            holder.visible: _foldersGrid.count === 0

            Keys.enabled: true
            Keys.priority: Keys.AfterItem
            Keys.onPressed: (event) =>
                            {

                                if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                                {
                                    openFolder(_foldersGrid.currentItem.path)
                                    event.accepted = true
                                    return
                                }

                                if(event.key === Qt.Key_F2)
                                {
                                    renameFolder()
                                    event.accepted = true
                                    return
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
        readonly property var folderInfo : list.getFolderInfo(currentFolder)

        headBar.visible: false
        title: control.folderInfo ? control.folderInfo.label : ""

        list.recursive: false
        list.urls: [currentFolder]
        list.activeGeolocationTags: browserSettings.gpsTags && !currentFolder.startsWith("gps:///")

        holder.emoji: "qrc:/assets/add-image.svg"
        holder.title : i18n("Folder is empty!")
        holder.body: i18n("There're no images in this folder. %1", list.urls)

        gridView.header: Loader
        {
            width: parent.width
            asynchronous: true
            sourceComponent: Column
            {
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

                Loader
                {
                    active: _picsView.list.activeGeolocationTags
                    asynchronous: true
                    width: parent.width

                    sourceComponent:  Flow
                    {
                        spacing: Maui.Style.space.medium
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
        if(String(url).startsWith("collection:///"))
        {
            control.pop()
        }else
        {
            control.push(picsViewComponent, ({'currentFolder': url}))
        }
    }else
    {
        if(currentFolder.startsWith("collection:///"))
        {
            if(String(url).startsWith("collection:///"))
            {
                return
            }else
            {
                control.push(picsViewComponent, ({'currentFolder': url}))
            }
        }else
        {
            if(String(url).startsWith("collection:///"))
            {
                control.pop()
            }else
            {
                control.currentItem.currentFolder = url
            }
        }
    }

    control.forceActiveFocus()
}
}
