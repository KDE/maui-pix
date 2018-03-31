import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
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
        }

        TextField
        {
            id: tagText
            placeholderText: "New tag..."
            Layout.fillWidth: true

        }

        Button
        {
            text: qsTr("Add")
            Layout.alignment: Qt.AlignRight
            onClicked: addTag(tagText.text, picUrl)

        }
    }

    function addTag(tag, url)
    {
       if(pix.picTag(tag, url))
           picTagged(tag)
       close()
    }

    function populate()
    {
        tagsList.model.clear()
        var tags = pix.get(Q.Query.allTags)

        if(tags.length > 0)
            for(var i in tags)
                tagsList.model.append(tags[i])

    }
}
