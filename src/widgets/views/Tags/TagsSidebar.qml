import QtQuick 2.9
import "../../../view_models"
import org.kde.maui 1.0 as Maui


PixPage
{

    property alias list : tagsList
    pageMargins : 0
    headerbarExit: false
    headerbarTitle: qsTr("Tags");
    clip: true

    headerBarLeft: Maui.ToolButton
    {
        iconName: "list-add"
    }

    headerBarRight: Maui.ToolButton
    {
        iconName: "list-remove"
    }

    content: ListView
    {
        id: tagsList
        clip: true

        height: parent.height
        width: parent.width
        focus: true

        highlightMoveDuration: 0
        highlightFollowsCurrentItem: true

        highlight: Rectangle
        {
            width: tagsList.width
            height: tagsList.currentItem.height
            color: highlightColor
        }


        model: ListModel{}

        delegate: PixDelegate
        {
            id: delegate
            label: tag

            Connections
            {
                target: delegate
                onClicked:
                {
                    tagsList.currentIndex = index
                    populateGrid(tagsList.model.get(index).tag)
                }
            }
        }
    }
}


