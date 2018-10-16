import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.mauikit 1.0 as Maui

ListView
{
    id: tagListRoot
    clip: true

    signal tagClicked(int index)

    focus: true
    interactive: true
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0

    Maui.Holder
    {
        id: holder
        emoji: "qrc:/img/assets/Electricity.png"
        visible: count === 0
        isMask: false
        title : "No tags!"
        body: "Start tagging your pics"
        emojiSize: iconSizes.huge
    }

    model: ListModel{}
    delegate: Maui.ListDelegate
    {
        id: delegate
        label: tag
        radius: radiusV
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
