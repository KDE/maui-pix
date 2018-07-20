import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import "../../../view_models"

Item
{
    property alias rollList : rollList

    property int rollHeight : iconSizes.large
    property int rollPicSize : rollHeight-space.tiny

    signal picClicked(int index)

    height: rollHeight
    width: parent.width


    Rectangle
    {
        anchors.fill: parent
        z:-1
        color: altColor
        radius: unit * 3
        opacity: 0.8
        border.color: Qt.darker(color, 1.5)
    }

    ListView
    {
        id: rollList
        width: parent.width* 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent
        currentIndex: currentPicIndex
        orientation: ListView.Horizontal
        clip: true
        spacing: space.small

        focus: true
        interactive: true

        model: ListModel{}

        delegate: PixPic
        {
            id: delegate
            picSize: rollPicSize
            height: rollPicSize
            width: rollPicSize
            anchors.verticalCenter: parent.verticalCenter

            picRadius: 0
            showLabel: false
            showIndicator: true
            showEmblem: false

            Connections
            {
                target: delegate
                onClicked:
                {
                    rollList.currentIndex = index
                    picClicked(index)
                }

                onPressAndHold: picMenu.show(rollList.model.get(index).url)
                onRightClicked: picMenu.show(rollList.model.get(index).url)
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
