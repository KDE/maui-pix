import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../db/Query.js" as Q
import "../../views/Pix.js" as PIX

import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{
    property var picUrls : []
    property bool forAlbum : false
    clip: true
    signal picTagged(string tag, string url)
    signal tagsAdded(var tags, var urls)

    maxHeight: unit * 500

    onAccepted: setTags()
    onRejected: close()
    onOpened: populate()

    ColumnLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            TagsList
            {
                id: tagsList

                width: parent.width
                height: parent.height
                onTagClicked:
                {
                    tagListComposer.model.insert(0, {tag: tagsList.model.get(index).tag})
                }
            }

        }


        Maui.TextField
        {
            id: tagText
            Layout.fillWidth: true
            placeholderText: "New tags..."
            onAccepted:
            {
                var tags = tagText.text.split(",")
                for(var i in tags)
                {
                    var myTag = tags[i].trim()
                    if(!tag.tagExists(myTag, true))
                        tagsList.model.insert(0, {tag: myTag})

                    tagListComposer.model.insert(0, {tag: myTag})

                }
                clear()
            }
        }


        Maui.TagList
        {
            id: tagListComposer
            Layout.fillWidth: true
            Layout.leftMargin: contentMargins
            Layout.rightMargin: contentMargins

            height: 64
            width: parent.width
            onTagRemoved:
            {
                pix.removePicTag(model.get(index).tag, pixViewer.currentPic.url)
                tagListComposer.model.remove(index)
            }
        }
    }

    function show(urls)
    {
        picUrls = urls
        open()
    }

    function setTags()
    {
        var tags = []

        for(var i = 0; i < tagListComposer.model.count; i++)
            tags.push(tagListComposer.model.get(i).tag)

        tagsAdded(tags, picUrls)
    }

    function addTagsToPic(urls, tags)
    {
        for(var j in urls)
        {
            var url = urls[j]
            if(tags.length > 0)
            {
                if(!pix.checkExistance("images", "url", url))
                    if(!pix.addPic(url))
                        return

                for(var i in tags)
                    if(PIX.addTagToPic(tags[i], url))
                        picTagged(tags[i], url)
            }

        }
        close()
    }

    function populate()
    {
        tagsList.model.clear()
        var tags = tag.getUrlsTags()

        if(tags.length > 0)
            for(var i in tags)
                tagsList.model.append(tags[i])


        if(picUrls.length === 1)
            tagListComposer.populate(forAlbum ? tag.getAbstractTags("album", picUrls[0], true) :
                                                tag.getUrlTags(picUrls[0], true))
    }
}
