import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

Item
{
    clip : true

    property alias tagsList : tagsList

    signal addClicked()
    signal tagRemovedClicked(int index)

    RowLayout
    {
        anchors.fill: parent
        PixButton
        {
            Layout.alignment: Qt.AlignLeft

            iconName: "list-add"

            onClicked: addClicked()
        }

        TagList
        {
            id: tagsList
            Layout.leftMargin: contentMargins
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
            Layout.fillWidth: true

            onTagRemoved: tagRemovedClicked(index)
        }
        TextInput
        {
            Layout.fillHeight: true
            Layout.fillWidth:true
            Layout.maximumWidth: parent.width-(tagsList.count*64)
            Layout.minimumWidth: 100
            Layout.alignment: Qt.AlignLeft
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            selectByMouse: !isMobile
            focus: true
            wrapMode: TextEdit.Wrap
            selectionColor: highlightColor
            selectedTextColor: highlightedTextColor

            onAccepted: tagsDialog.addTagsToPic(currentPic.url, text.split(","))
        }
    }
}
