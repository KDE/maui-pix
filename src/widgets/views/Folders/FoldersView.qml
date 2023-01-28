import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

import org.mauikit.filebrowsing 1.3 as FB

import org.maui.pix 1.0

import "../../../view_models"
import "../.."

Maui.SideBarView
{
    id: control
    property string currentFolder : initData
    readonly property var folderInfo : FB.FM.getFileInfo(currentFolder)
    property alias picsView : _stackView.currentItem
    property Flickable flickable : picsView.flickable

       sideBar.enabled: browserSettings.showSidebar
    sideBar.content: Sidebar
    {
        anchors.fill: parent
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent


        Component.onCompleted:
        {
            if(_foldersViewLoader.pendingFolder.length > 0)
            {
                openFolder(_foldersViewLoader.pendingFolder)
            }
        }

        initialItem: Maui.Page
        {
            id: _foldersPage
            Maui.Theme.inherit: false
            Maui.Theme.colorGroup: Maui.Theme.View

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


            headBar.leftContent:     ToolButton
            {
               visible: browserSettings.showSidebar

                icon.name: sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
                onClicked: sideBar.toggle()
                checked: sideBar.visible
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Toggle sidebar")
            }

            Maui.GridBrowser
            {
                id: _foldersGrid
                anchors.fill: parent
                itemSize: Math.min(260, Math.max(100, Math.floor(width* 0.3)))
                itemHeight: itemSize + Maui.Style.rowHeight
                currentIndex: -1
                holder.emoji: "qrc:/assets/view-preview.svg"
                holder.title : i18n("No Folders!")
                holder.body: i18n("Add new image sources")
                holder.visible: foldersList.count === 0

                onKeyPress:
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
                        images: _galleryList.files
                        label1.text: model.label
                        label2.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")

                        draggable: true

                        Drag.keys: ["text/uri-list"]
                        Drag.mimeData: Drag.active ? { "text/uri-list": model.path } : {}

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
            headBar.visible: true
            title: _stackView.folderInfo.label

            headBar.farLeftContent: ToolButton
            {
                icon.name:"go-previous"
                onClicked:
                {
                    _stackView.pop()
                    control.currentFolder = ""
                }
            }

            list.recursive: false

            holder.emoji: "qrc:/assets/add-image.svg"
            holder.title : i18n("Folder is empty!")
            holder.body: i18n("There're no images in this folder")

            gridView.header: Maui.SectionHeader
            {
                width: parent.width
//                padding: Maui.Style.space.big
//                spacing: 0
                label1.text: control.folderInfo.label
                label2.text: (control.folderInfo.url).replace(FB.FM.homePath(), "")
                template.label3.text: _picsView.gridView.count
                template.label4.text: Qt.formatDateTime(new Date(_stackView.folderInfo.modified), "d MMM yyyy")
                template.iconSource: control.folderInfo.icon

                template.content: ToolButton
                {
                    icon.name: "folder-open"
                    onClicked: Pix.Collection.showInFolder([control.currentFolder])
                }

            }
        }
    }

}


function refresh()
{
    foldersList.refresh()
}

function openFolder(url)
{
    control.currentFolder = url

    if(_stackView.depth == 1)
    {
        _stackView.push(picsViewComponent)
    }
    picsView.list.urls = [url]

}
}
