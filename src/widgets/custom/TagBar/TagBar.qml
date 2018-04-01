import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

Rectangle
{
    color: "transparent"
    clip : true

    property alias tagsList : tagsList

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

            onTagRemoved: if(pix.removePicTag(tagsList.model.get(index).tag, pixViewer.currentPic.url))
                              tagsList.model.remove(index)
        }
    }
}
