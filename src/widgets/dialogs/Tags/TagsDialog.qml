import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../custom/TagBar"
import "../../../db/Query.js" as Q

PixPopup
{
    padding: contentMargins*2
    width: 200

    property string picUrl : ""

    onOpened: populate()

    signal picTagged(string tag)

    ColumnLayout
    {
        anchors.fill: parent

        TagsList
        {
            id: tagsList
            Layout.fillHeight: true
            Layout.fillWidth: true
            width: parent.width
            height: parent.height

            onTagClicked:
            {
                tagListComposer.model.insert(0, {tag: tagsList.model.get(index).tag})
            }
        }

        TextField
        {
            id: tagText
            Layout.fillWidth: true

            placeholderText: "Tags..."
            onAccepted:
            {
                var tags = tagText.text.split(",")
                for(var i in tags)
                {
                    var tag = tags[i].trim()
                    if(!pix.checkExistance("tags", "tag", tag))
                    {
                        tagsList.model.insert(0, {tag: tag})
                        tagListComposer.model.insert(0, {tag: tag})
                    }
                }

                clear()
            }
        }


        TagList
        {
            id: tagListComposer
            Layout.fillWidth: true
            height: 64
            width: parent.width
            onTagRemoved:
            {
                pix.removePicTag(model.get(index).tag, pixViewer.currentPic.url)
                tagListComposer.model.remove(index)
            }
        }



        Button
        {
            text: qsTr("Add")
            onClicked: addTags(picUrl)
        }
    }

    function addTags(url)
    {
        var tags = []

        for(var i = 0; i < tagListComposer.model.count; i++)
            tags.push(tagListComposer.model.get(i))

        if(tags.length > 0)
            for(i in tags)
            {
                if(pix.picTag(tags[i].tag, url))
                    picTagged(tags[i].tag)
            }

        close()
    }

    function populate()
    {
        tagsList.model.clear()
        var tags = pix.get(Q.Query.allTags)

        if(tags.length > 0)
            for(var i in tags)
                tagsList.model.append(tags[i])

        tagListComposer.populate(picUrl)
    }
}
