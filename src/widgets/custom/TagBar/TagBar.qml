import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../dialogs/Tags"
import "../../../db/Query.js" as Q

ToolBar
{
    position: ToolBar.Footer
    clip : true
    TagsDialog
    {
        id: tagsDialog

        onPicTagged: tagsList.model.append({"tag": tag})
    }

    RowLayout
    {
        anchors.fill: parent
        PixButton
        {
            Layout.alignment: Qt.AlignLeft

            iconName: "list-add"

            onClicked:
            {
                tagsDialog.picUrl = pixViewer.currentPic.url
                tagsDialog.open()
            }

        }

        TagList
        {
            id: tagsList
            Layout.leftMargin: contentMargins
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    function populate(url)
    {
        console.log("trying ot get tag for ", Q.Query.picTags_.arg(url))

        tagsList.model.clear()
        var tags = pix.get(Q.Query.picTags_.arg(url))

        if(tags.length > 0)
            for(var i in tags)
                tagsList.model.append(tags[i])

    }
}
