import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.pix 1.0 as Pix

import "../../../view_models"
import "../../../db/Query.js" as Q

StackView
{
    id: control
    clip: true

    property string currentTag : ""

    Maui.NewDialog
    {
        id: newTagDialog
        title: qsTr("New tag")
        message: qsTr("Create a new tag to organize your gallery")
        acceptButton.text : qsTr("Add")
        onFinished:
        {
            tagsList.insert(text)
        }
    }

    initialItem: TagsSidebar
    {
        id: tagsSidebar
    }

    PixGrid
    {
        id: tagsGrid
        title: control.currentTag
        holder.title: qsTr("No Pics!")
        holder.body: qsTr("There's no pics associated with the tag")
        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.emoji: "qrc:/img/assets/add-image.svg"

        headBar.leftContent: ToolButton
        {
            icon.name: "go-previous"
            onClicked: control.pop()
        }
    }

    function refreshPics()
    {
        tagsGrid.list.refresh()
    }

    function populateGrid(myTag)
    {
        tagsGrid.list.clear()
        control.push(tagsGrid)

        const urls = Pix.Tag.getUrls(myTag, true);
        console.log(urls)
        if(urls.length > 0)
            for(const i in urls)
            {
                if(Maui.FM.checkFileType(Maui.FMList.IMAGE, urls[i].mime))
                    tagsGrid.list.append(urls[i].url)
            }

    }
 }
