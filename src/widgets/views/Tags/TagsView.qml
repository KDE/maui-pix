import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import "../../../view_models"
import "../../../db/Query.js" as Q

Kirigami.PageRow
{
    id: tagsPageRoot
    clip: true

    separatorVisible: wideMode
    initialPage: [tagsSidebar, tagsGrid]
    defaultColumnWidth: Kirigami.Units.gridUnit * 15
    interactive: currentIndex === 1

    property string currentTag : ""

    Connections
    {
        target: pix
        onTagAdded: tagsSidebar.list.model.insert(tagsSidebar.list.count, {"tag": tag})
    }

    TagsSidebar
    {
        id: tagsSidebar
    }

    PixGrid
    {
        id: tagsGrid
        headBarExit: !wideMode
        headBarExitIcon: "go-previous"
        onExit: if(!wideMode) currentIndex = 0
    }

    function populate()
    {
        tagsSidebar.list.model.clear()
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
