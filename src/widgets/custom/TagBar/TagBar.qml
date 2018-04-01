import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

Item
{
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

            Label
            {
                height: parent.height
                width: parent.width
                text: qsTr("Add tags...")
                opacity: 0.5
                visible: tagsList.count === 0
                font.pointSize: fontSizes.default
            }
        }
    }
}
