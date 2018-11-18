import QtQuick 2.9
import "../../../view_models"
import org.kde.mauikit 1.0 as Maui


Maui.Page
{
    margins:0
    headBarExit: false
    headBarTitle: qsTr("Tags")
    headBar.plegable: false

    clip: true

    headBar.leftContent: Maui.ToolButton
    {
        iconName: "list-add"
        onClicked: newTagDialog.open()
    }

    headBar.rightContent: Maui.ToolButton
    {
        iconName: "list-remove"
    }

    Maui.Holder
    {
        visible: _tagsList.count === 0
        emoji: "qrc:/img/assets/Rainbow.png"
        isMask: false
        title : "No Tags!"
        body: "You can create new tags"
        emojiSize: iconSizes.huge
        z: 999
    }

    Maui.SideBar
    {
        id: _tagsList
        anchors.fill: parent
        model: tagsModel
        delegate: Maui.ListDelegate
        {
            id: delegate
            label: tag

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


