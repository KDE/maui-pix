import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"

PixPage
{
    headerbarExit: stackView.currentItem === picsView
    headerbarExitIcon: "go-previous"
    headerbarTitle: qsTr("Folders")

    onExit: stackView.pop(folderGrid)

    content: StackView
    {
        id: stackView
        height: parent.height
        width: parent.width

        initialItem: FoldersGrid
        {
            id: folderGrid

            onFolderClicked:
            {
                headerbarTitle = folderGrid.model.get(index).folder
                picsView.clear()
                picsView.populate(folderGrid.model.get(index).url)
                if(stackView.currentItem === folderGrid)
                    stackView.push(picsView)
            }
        }

        PicsView
        {
            id: picsView
            headerbarVisible: false

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
