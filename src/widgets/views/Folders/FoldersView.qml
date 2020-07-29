import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.12 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "../../../view_models"

import FoldersList 1.0
import GalleryList 1.0

StackView
{
    id: _stackView

    property string currentFolder : ""
    property alias picsView : _stackView.currentItem
    property Flickable flickable : picsView.flickable

    initialItem: Maui.GridView
    {
        id: foldersPage
        itemSize: Math.min(200, _stackView.width/3)
        margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.big

        model: Maui.BaseModel
        {
            id: folderModel
            list: FoldersList
            {
                id: foldersList
                folders: _galleryView.list.folders
            }
            recursiveFilteringEnabled: false
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        Maui.Holder
        {
            id: holder
            emoji: "qrc:/assets/view-preview.svg"
            title : i18n("No Folders!")
            body: i18n("Add new image sources")
            emojiSize: Maui.Style.iconSizes.huge
            visible: false
        }

        delegate: Maui.ItemDelegate
        {
            id: _delegate
            property var folderPath : [model.path]
            height: foldersPage.cellHeight - Maui.Style.space.medium
            width: foldersPage.cellWidth - Maui.Style.space.medium
            isCurrentItem: GridView.isCurrentItem

            onClicked:
            {
                foldersPage.currentIndex = index

                if(Maui.Handy.singleClick)
                {
                    _stackView.push(picsViewComponent)
                    var folder = folderModel.get(foldersPage.currentIndex)
                    picsView.title = folder.label
                    currentFolder = folder.path
                    picsView.list.urls = [currentFolder]
                }
            }

            onDoubleClicked:
            {
                foldersPage.currentIndex = index

                if(!Maui.Handy.singleClick)
                {
                    _stackView.push(picsViewComponent)
                    var folder = folderModel.get(foldersPage.currentIndex)
                    picsView.title = folder.label
                    currentFolder = folder.path
                    picsView.list.urls = [currentFolder]
                }
            }

            ColumnLayout
            {
                width: foldersPage.itemSize - 10
                height: foldersPage.cellHeight - 20
                anchors.centerIn: parent
                spacing: Maui.Style.space.small

                Item
                {
                    id: _collageLayout
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item
                    {
                        anchors.fill: parent

                        GridLayout
                        {
                            anchors.fill: parent
                            columns: 2
                            rows: 2
                            columnSpacing: 2
                            rowSpacing: 2

                            Repeater
                            {
                                model: Maui.BaseModel
                                {
                                    list: GalleryList
                                    {
                                        urls: folderPath
                                        autoReload: false
                                        recursive: false
                                        limit: 4
                                    }
                                }

                                delegate: Rectangle
                                {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: Qt.rgba(0,0,0,0.3)
                                    Image
                                    {
                                        anchors.fill: parent
                                        sourceSize.width: 80
                                        sourceSize.height: 80
                                        asynchronous: true
                                        smooth: false
                                        source: model.url
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }
                            }
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask
                        {
                            cached: true
                            maskSource: Item
                            {
                                width: _collageLayout.width
                                height: _collageLayout.height

                                Rectangle
                                {
                                    anchors.fill: parent
                                    radius: 8
                                }
                            }
                        }
                    }
                }

                Maui.ListItemTemplate
                {
                    Layout.fillWidth: true
                    label1.text: model.label
                    label3.text: Maui.FM.formatDate(model.modified, "dd/MM/yyyy")
                    rightLabels.visible: true
                    iconSource: model.icon
                    iconSizeHint: Maui.Style.iconSizes.small
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
                onClicked: _stackView.pop()
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
