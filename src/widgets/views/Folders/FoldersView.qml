import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.kirigami 2.2 as Kirigami

Kirigami.PageRow
{
    id: foldersPageRoot
    separatorVisible: foldersPageRoot.wideMode
    initialPage: [foldersPage, picsView]
    defaultColumnWidth: parent.width
    interactive: foldersPageRoot.currentIndex  === 1
    clip: true

    PixPage
    {
        id: foldersPage
        anchors.fill: parent

        headerbarVisible: false
        headerbarExit: false

        content: FoldersGrid
        {
            id: folderGrid

            onFolderClicked:
            {
                folderGrid.currentIndex = index
                picsView.headerbarTitle = folderGrid.model.get(index).folder
                picsView.clear()
                picsView.populate(folderGrid.model.get(index).url)
                foldersPageRoot.currentIndex = 1
            }
        }
    }

    PicsView
    {
        id: picsView
        anchors.fill: parent

        headerbarVisible: true
        headerbarExit: foldersPageRoot.currentIndex === 1
        headerbarExitIcon: "go-previous"
        onExit: foldersPageRoot.currentIndex = 0
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
