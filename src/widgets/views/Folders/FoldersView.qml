import QtQuick 2.0
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

import "../../../view_models"
import "../../../db/Query.js" as Q

import FoldersList 1.0

StackView
{
    id: _stackView
    //    separatorVisible: foldersPageRoot.wideMode
    //    initialPage: [foldersPage, picsView]
    //    defaultColumnWidth: width

    //    interactive: foldersPageRoot.currentIndex  === 1
    clip: true

    property string currentFolder : ""
    property alias picsView : picsView

    initialItem: Maui.Page
    {
        id: foldersPage
        padding: 0

        Maui.Holder
        {
            id: holder
            emoji: "qrc:/img/assets/view-preview.svg"
            title : qsTr("No Folders!")
            body: qsTr("Add new image sources")
            emojiSize: Maui.Style.iconSizes.huge
            visible: false
        }

        Maui.BaseModel
        {
            id: folderModel
            list: foldersList
            recursiveFilteringEnabled: false
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive            
        }

        FoldersList
        {
            id: foldersList
        }

        Maui.GridBrowser
        {
            id: folderGrid
            anchors.fill: parent
            showEmblem: false
            model: folderModel

            gridView.header: Maui.ToolBar
            {
                width: parent.width

                middleContent:  Maui.TextField
                {
                    id: _filterField
                    Layout.margins: Maui.Style.space.medium
                    Layout.fillWidth: true
                    placeholderText: qsTr("Filter...")
                    onAccepted: folderModel.filter = text
                    onCleared: folderModel.filter = ""
                }
            }

            onItemClicked:
            {
                var folder = folderModel.get(index)
                picsView.title = folder.label
                currentFolder = folder.path
                picsView.list.query = Q.Query.picLikeUrl_.arg(currentFolder)
                _stackView.push(picsView)
            }
        }
    }

    PixGrid
    {
        id: picsView

        headBar.visible: true
        //        headBarExit: _stackView.currentItem === picsView
        //        headBarExitIcon: "go-previous"
        //        onExit: _stackView.pop()

        headBar.leftContent: ToolButton
        {
            icon.name:"go-previous"
            onClicked: _stackView.pop()
        }

        holder.emoji: "qrc:/img/assets/add-image.svg"
        holder.title : qsTr("Folder is empty!")
        holder.body: qsTr("There's not images in this folder")
        holder.emojiSize: Maui.Style.iconSizes.huge
    }

    function refresh()
    {
        foldersList.refresh()
    }
}
