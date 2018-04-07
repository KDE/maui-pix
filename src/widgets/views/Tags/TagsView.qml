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
        onPicClicked: openPic(index)
    }

    function openPic(index)
    {
        var data = []
        for(var i = 0; i < grid.model.count; i++)
            data.push(grid.model.get(i))

        VIEWER.open(data, index)
    }

    function populate()
    {
        var tags = pix.get(Q.Query.allTags)

        if(tags.length > 0)
            for(var i in tags)
                tagsSidebar.list.model.append(tags[i])

    }

    function populateGrid(tag)
    {
        if(!wideMode && currentIndex === 0)
            currentIndex = 1


        tagsGrid.grid.model.clear()
        var tags = pix.get(Q.Query.tagPics_.arg(tag))

        if(tags.length > 0)
            for(var i in tags)
                tagsGrid.grid.model.append(tags[i])

    }

    function clear()
    {
        tagsSidebar.list.model.clear()
        tagsGrid.grid.model.clear()
    }

}
