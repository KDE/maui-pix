import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui

Kirigami.PageRow
{
    id: foldersPageRoot
    separatorVisible: foldersPageRoot.wideMode
    initialPage: [foldersPage, picsView]
    defaultColumnWidth: parent.width
    interactive: foldersPageRoot.currentIndex  === 1
    clip: true

    property string currentFolder : ""
    property alias picsView : picsView

    Maui.Page
    {
        id: foldersPage
        anchors.fill: parent

        headBarVisible: false
        margins: space.huge

        FoldersGrid
        {
            id: folderGrid

            onFolderClicked:
            {
                folderGrid.currentIndex = index
                picsView.headBarTitle = folderGrid.model.get(index).label
                picsView.clear()
                currentFolder = folderGrid.model.get(index).path
                picsView.populate(currentFolder)
                foldersPageRoot.currentIndex = 1
            }
        }
    }

    PicsView
    {
        id: picsView
        anchors.fill: parent

        headBarVisible: true
        headBarExit: foldersPageRoot.currentIndex === 1
        headBarExitIcon: "go-previous"
        onExit: foldersPageRoot.currentIndex = 0

        holder.emoji: "qrc:/img/assets/Electricity.png"
        holder.isMask: false
        holder.title : "Folder is empty!"
        holder.body: "There's not images on this folder"
        holder.emojiSize: iconSizes.huge
    }

    function populate()
    {
        clear()
        var folders = pix.getFolders()
        if(folders.length > 0)
            for(var i in folders)
                folderGrid.model.append(folders[i])

    }

    function clear()
    {
        folderGrid.model.clear()
    }

}
