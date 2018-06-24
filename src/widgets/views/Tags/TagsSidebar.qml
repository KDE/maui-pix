import QtQuick 2.9
import "../../../view_models"
import org.kde.maui 1.0 as Maui


Maui.Page
{
    property alias list : tagsList
    margins:0
    headBarExit: false
    headBarTitle: qsTr("Tags");
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

    Maui.SideBar
    {
        id: tagsList

        height: parent.height
        width: parent.width
        delegate: Maui.ListDelegate
        {
            id: delegate
            label: tag

            Connections
            {
                target: delegate
                onClicked:
                {
                    tagsList.currentIndex = index
                    currentTag = tagsList.model.get(index).tag
                    populateGrid(currentTag)
                }
            }
        }
    }
}


