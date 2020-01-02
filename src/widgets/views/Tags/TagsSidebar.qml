import QtQuick 2.9
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control
    padding:0
    title: qsTr("Tags")

    headBar.leftContent: ToolButton
    {
        icon.name: "list-add"
        onClicked: newTagDialog.open()
    }

//    headBar.rightContent: ToolButton
//    {
//        icon.name: "list-remove"
//    }

    Maui.Holder
    {
        visible: _tagsList.count === 0
        emoji: qsTr("qrc:/img/assets/add-image.svg")
        isMask: false
        title :qsTr("No Tags!")
        body: qsTr("You can create new tags to organize your gallery")
        emojiSize: Maui.Style.iconSizes.huge
        z: 999
        onActionTriggered: newTagDialog.open()
    }

    Maui.GridView
    {
        id: _tagsList
        anchors.fill: parent
        model: tagsModel
        itemSize: 100
        adaptContent: true

        delegate: Maui.ItemDelegate
        {
            id: delegate
            isCurrentItem:  GridView.isCurrentItem
            height: _tagsList.cellHeight
            width: _tagsList.cellWidth
            padding: Maui.Style.space.medium

            Maui.GridItemTemplate
            {
                anchors.fill: parent
                label1.text: model.tag
                iconSource: "tag"
            }

            Connections
            {
                target: delegate
                onClicked:
                {
                    _tagsList.currentIndex = index
                    currentTag = tagsList.get(index).tag
                    populateGrid(currentTag)
                }
            }
        }
    }
}


