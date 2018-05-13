import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.maui 1.0 as Maui
Item
{
    clip : true

    property alias tagsList : tagsList

    property bool editMode : false
    property bool allowEditMode : false

    signal addClicked()
    signal tagRemovedClicked(int index)
    signal tagsEdited(var tags)

    RowLayout
    {
        anchors.fill: parent
        spacing: 0
        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: !editMode
            RowLayout
            {
                anchors.fill: parent
                spacing: 0

                Maui.ToolButton
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
                    MouseArea
                    {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onClicked: if(allowEditMode) goEditMode()
                    }
                }
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: editMode

            RowLayout
            {
                anchors.fill: parent
                spacing: 0
                Item
                {
                    Layout.fillHeight: true
                    Layout.fillWidth:true
                    //                    Layout.margins: space.big
                    TextInput
                    {
                        id: editTagsEntry
                        anchors.fill: parent

                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment:  Text.AlignVCenter
                        selectByMouse: !isMobile
                        focus: true
                        wrapMode: TextEdit.Wrap
                        color: textColor
                        selectionColor: highlightColor
                        selectedTextColor: highlightedTextColor
                        onFocusChanged: editMode = false
                        onAccepted: saveTags()
                    }
                }

                Maui.ToolButton
                {
                    Layout.alignment: Qt.AlignLeft
                    iconName: "checkbox"
                    onClicked: saveTags()
                }
            }
        }
    }

    function goEditMode()
    {
        var currentTags = []
        for(var i = 0 ; i < tagsList.count; i++)
            currentTags.push(tagsList.model.get(i).tag)

        editTagsEntry.text = currentTags.join(", ")
        editMode = true
        editTagsEntry.forceActiveFocus()
    }

    function saveTags()
    {
        var tags = editTagsEntry.text.split(",")
        tagsEdited(tags)
        editMode = false
    }
}
