import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"

ListView
{
    id: tagListRoot
    clip: true

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

    PixHolder
    {
        id: holder
        message: "<h2>No Tags!</h2><p>Start tagging your pics</p>"
        emoji: "qrc:/img/assets/face.png"
        visible: count === 0
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
                tagListRoot.currentIndex = index
                tagClicked(index)
            }
        }
    }
}
