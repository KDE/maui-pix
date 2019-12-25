import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "../../../view_models"
import GalleryList 1.0

Item
{
    property alias rollList : rollList

    property int rollPicSize : height-Maui.Style.space.tiny

    signal picClicked(int index)

    ListView
    {
        id: rollList
        width: parent.width* 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent
        currentIndex: currentPicIndex
        orientation: ListView.Horizontal
        clip: true
        spacing: Maui.Style.space.big

        focus: true
        interactive: true

        model: currentModel

        delegate: PixPic
        {
            id: delegate
            height: 100
            width: 100

            picRadius: Maui.Style.radiusV
            showLabel: false
            showIndicator: true
            fit: false
            showEmblem: false
            dropShadow: true
            isCurrentItem: ListView.isCurrentItem

            Connections
            {
                target: delegate
                onClicked:
                {
                    rollList.currentIndex = index
                    picClicked(index)
                }

                onPressAndHold: _picMenu.popup()
                onRightClicked: _picMenu.popup()
            }
        }
    }

    function populate(pics)
    {
        rollList.model.clear()
        if(pics.length > 0)
            for(var i in pics)
                rollList.model.append(pics[i])
    }

    function position(index)
    {
        rollList.currentIndex = index
        rollList.positionViewAtIndex(index, ListView.Center)
    }

}
