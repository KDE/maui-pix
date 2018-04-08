import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import "../../../view_models"

Item
{
    property alias rollList : rollList

    property int rollHeight : 54
    property int rollPicSize : rollHeight-6

    signal picClicked(int index)

    height: rollHeight
    width: parent.width


    Rectangle
    {
        anchors.fill: parent
        z:-1
        color: Kirigami.Theme.complementaryBackgroundColor
        radius: 4
        opacity: 0.8
        border.color: "black"
    }

    ListView
    {
        id: rollList
        width: parent.width* 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent

        orientation: ListView.Horizontal
        clip: true
        spacing: 2

        focus: true
        interactive: true

        model: ListModel{}

        delegate: PixPic
        {
            id: delegate
            picSize: rollPicSize
            picRadius: 0
            showLabel: false
            showIndicator: true

            Connections
            {
                target: delegate
                onClicked:
                {
                    rollList.currentIndex = index
                    picClicked(index)
                }
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
