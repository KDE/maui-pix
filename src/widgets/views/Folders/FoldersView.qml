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
            height: foldersPage.cellHeight
            width: foldersPage.cellWidth
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
                            columnSpacing: 0
                            rowSpacing: 0

                            Repeater
                            {
                                model: Maui.BaseModel
                                {
                                    list: GalleryList
                                    {
                                        urls: folderPath
                                        autoReload: false
                                        //                                autoScan: false
                                        recursive: false
                                        limit: 4
                                    }
                                    recursiveFilteringEnabled: false
                                    sortCaseSensitivity: Qt.CaseInsensitive
                                    filterCaseSensitivity: Qt.CaseInsensitive
                                }

                                delegate: PixPic
                                {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    labelsVisible: false
                                    checkable: false
                                    draggable: false
                                    enabled: false
                                    radius: 0
                                    imageBorder: false
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


                    Rectangle
                    {
                        anchors.fill: parent
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.4)
                        radius: Maui.Style.radiusV
                        opacity: 0.2
                        color: control.hovered ? control.Kirigami.Theme.highlightColor : "transparent"
                    }

                }


                Maui.ListItemTemplate
                {
                    Layout.fillWidth: true
                    label1.text: model.label
                    label3.text: Maui.FM.formatDate(model.modified, "dd/MM/yyyy")
                    rightLabels.visible: true
                    //                    label2.text: model.count
                    iconSource: model.icon
                    iconSizeHint: Maui.Style.iconSizes.small

                    //                    horizontalAlignment: Qt.AlignLeft
                    //                    font.bold: true
                    //                    font.weight: Font.Bold
                    //                    elide: Text.ElideMiddle
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
