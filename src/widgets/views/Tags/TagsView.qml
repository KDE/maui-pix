import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

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

    Maui.NewDialog
    {
        id: newTagDialog
        title: qsTr("New tag")
        onFinished:
        {
            tag.tag(text)
        }
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
        holder.title: "No Pics!"
        holder.body: "There's no pics associated with the tag"
        holder.isMask: false
        holder.emojiSize: iconSizes.huge
        holder.emoji: "qrc:/img/assets/Bread.png"
    }

    function populate()
    {
        tagsSidebar.list.model.clear()
        var tags = tag.getUrlsTags(true)

        if(tags.length > 0)
            for(var i in tags)
                append(tags[i])

    }

    function populateGrid(myTag)
    {
        if(!wideMode && currentIndex === 0)
            currentIndex = 1

        tagsGrid.model.clear()
        var tags = tag.getUrls(myTag);

        if(tags.length > 0)
            for(var i in tags)
                tagsGrid.model.append(tags[i])

    }

    function clear()
    {
        tagsSidebar.list.model.clear()
        tagsGrid.model.clear()
    }

    function append(myTag)
    {
        tagsSidebar.list.model.append(myTag)
    }

}
