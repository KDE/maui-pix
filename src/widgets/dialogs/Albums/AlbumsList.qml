import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"

ListView
{
    id: tagListRoot

    signal tagClicked(int index)

    highlight: Rectangle
    {
        width: tagListRoot.width
        height: tagListRoot.currentItem.height
        color: highlightColor
    }

    focus: true
    interactive: true
    highlightFollowsCurrentItem: true

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
                tagListRoot.currentIndex = index
                tagClicked(index)
            }
        }
    }
}
