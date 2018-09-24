import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.mauikit 1.0 as Maui

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
        emoji: "qrc:/img/assets/RedPlanet.png"
        isMask: false
        title : "No albums!"
        body: "Start creating new albums"
        emojiSize: iconSizes.huge
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
