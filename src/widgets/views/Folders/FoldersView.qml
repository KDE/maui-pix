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

    property string currentFolder : ""
    property alias picsView : _stackView.currentItem
    property Flickable flickable : picsView.flickable

    initialItem: Maui.GridBrowser
    {
        id: foldersPage
        checkable: false
        model: folderModel

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

        onItemClicked:
        {
            foldersPage.currentIndex = index

            if(Maui.Handy.singleClick)
            {
                _stackView.push(picsViewComponent)
                var folder = folderModel.get(foldersPage.currentIndex)
                picsView.title = folder.label
                currentFolder = folder.path
                picsView.list.query = Q.Query.picLikeUrl_.arg(currentFolder)
            }
        }

        onItemDoubleClicked:
        {
            foldersPage.currentIndex = index

            if(!Maui.Handy.singleClick)
            {
                _stackView.push(picsViewComponent)
                var folder = folderModel.get(foldersPage.currentIndex)
                picsView.title = folder.label
                currentFolder = folder.path
                picsView.list.query = Q.Query.picLikeUrl_.arg(currentFolder)
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

            holder.emoji: "qrc:/img/assets/add-image.svg"
            holder.title : qsTr("Folder is empty!")
            holder.body: qsTr("There's not images in this folder")
            holder.emojiSize: Maui.Style.iconSizes.huge
        }
    }

    function refresh()
    {
        foldersList.refresh()
    }
}
