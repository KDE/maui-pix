import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.maui 1.0 as Maui

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
    highlightMoveDuration: 0

    Maui.Holder
    {
        id: holder
        message: "<h2>No Albums!</h2><p>Start creating new albums</p>"
        emoji: "qrc:/img/assets/face.png"
        visible: count === 0
    }

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
