import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.mauikit 1.0 as Maui

ListView
{
    id: albumsListRoot

    signal albumClicked(int index)

    focus: true
    interactive: true
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0

    Maui.Holder
    {
        id: holder
        emoji: "qrc:/img/assets/RedPlanet.png"
        isMask: false
        title : qsTr("No albums!")
        body: qsTr("Start creating new albums")
        emojiSize: iconSizes.huge
        visible: count === 0
    }

    model: ListModel{}
    delegate: Maui.ListDelegate
    {
        id: delegate
        label: album
        radius: radiusV

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
