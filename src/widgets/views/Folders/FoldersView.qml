import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"

Page
{
    StackView
    {
        id: stackView
        height: parent.height
        width: parent.width

        initialItem: PixPage
        {
            id: foldersPage
            headerbarVisible: false
            headerbarExit: false
            topPadding: contentMargins

            content: FoldersGrid
            {
                id: folderGrid

                onFolderClicked:
                {
                    folderGrid.currentIndex = index
                    picsView.headerbarTitle = folderGrid.model.get(index).folder
                    picsView.clear()
                    picsView.populate(folderGrid.model.get(index).url)
                    if(stackView.currentItem === foldersPage)
                        stackView.push(picsView)
                }
            }
        }

        PicsView
        {
            id: picsView
            headerbarVisible: true
            headerbarExit: stackView.currentItem === picsView
            headerbarExitIcon: "go-previous"
            onExit: stackView.pop(foldersPage)
        }
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
