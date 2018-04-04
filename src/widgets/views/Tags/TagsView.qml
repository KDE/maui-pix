import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import "../../../view_models"
import "../../../db/Query.js" as Q

Kirigami.PageRow
{
    clip: true

    separatorVisible: wideMode
    initialPage: [tagsSidebar, tagsGrid]
    defaultColumnWidth: Kirigami.Units.gridUnit * 15
    interactive: false

    TagsSidebar
    {
        id: tagsSidebar
    }

    PixGrid
    {
        id: tagsGrid
        headerbarExit: !wideMode
        headerbarExitIcon: "arrow-left"
        onExit: if(!wideMode) currentIndex = 0
    }

    function populate()
    {
        var tags = pix.get(Q.Query.allTags)

        if(tags.length > 0)
            for(var i in tags)
                tagsSidebar.list.model.append(tags[i])

    }

    function populateGrid()
    {

    }

    function clear()
    {
        tagsSidebar.list.model.clear()
        tagsGrid.grid.model.clear()
    }

}
