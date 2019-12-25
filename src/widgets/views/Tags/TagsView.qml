import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.pix 1.0 as Pix

import "../../../view_models"
import "../../../db/Query.js" as Q

Kirigami.PageRow
{
    id: tagsPageRoot
    clip: true

    separatorVisible: false
    initialPage: [tagsSidebar, tagsGrid]
    defaultColumnWidth: Kirigami.Units.gridUnit * 15
    interactive: currentIndex === 1

    property string currentTag : ""


    Maui.NewDialog
    {
        id: newTagDialog
        title: qsTr("New tag")
        onFinished:
        {
            tagsList.insert(text)
        }
    }

    TagsSidebar
    {
        id: tagsSidebar
    }

    PixGrid
    {
        id: tagsGrid
//        headBarExit: !wideMode
//        headBarExitIcon: "go-previous"
//        onExit: if(!wideMode) currentIndex = 0
        holder.title: "No Pics!"
        holder.body: "There's no pics associated with the tag"
        holder.isMask: false
        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.emoji: "qrc:/img/assets/Bread.png"
    }

    function refreshPics()
    {
        tagsGrid.list.refresh()
    }

     function populateGrid(myTag)
    {
         tagsGrid.list.clear()
        if(!wideMode && currentIndex === 0)
            currentIndex = 1

        const urls = Pix.Tag.getUrls(myTag, true);

        if(urls.length > 0)
            for(const i in urls)
                tagsGrid.list.append(urls[i].url)

    }
 }
