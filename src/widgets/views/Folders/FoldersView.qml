import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"


PixPage
{

    content: FoldersGrid
    {
        id: folderGrid
    }

    function populate()
    {
        var folders = pix.getFolders()
        if(folders.length > 0)
            for(var i in folders)
                folderGrid.model.append(folders[i])

    }
}
