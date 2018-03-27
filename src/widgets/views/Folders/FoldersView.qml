import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"

PixPage
{
    headerbarExit: false
    headerbarTitle: qsTr("Folders")

    content: FoldersGrid
    {
        id: folderGrid

        onFolderClicked:
        {
            headerbarTitle = folderGrid.model.get(index).folder
        }
    }



    function populate()
    {
        var folders = pix.getFolders()
        if(folders.length > 0)
            for(var i in folders)
                folderGrid.model.append(folders[i])

    }
}
