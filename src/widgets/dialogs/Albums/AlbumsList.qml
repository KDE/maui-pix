import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"

ListView
{
    id: albumsListRoot

    signal albumClicked(int index)

    highlight: Rectangle
    {
        width: albumsListRoot.width
        height: albumsListRoot.currentItem.height
        color: highlightColor
    }

    focus: true
    interactive: true
    highlightFollowsCurrentItem: true

    model: ListModel{}
    delegate: PixDelegate
    {
        id: delegate
        label: album

        Connections
        {
            target: delegate
            onClicked:
            {
                albumsListRoot.currentIndex = index
                albumClicked(index)
            }
        }
    }
}
