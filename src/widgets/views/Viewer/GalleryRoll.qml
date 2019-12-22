import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import "../../../view_models"

Item
{
    property alias rollList : rollList

    property int rollHeight : Maui.Style.iconSizes.large
    property int rollPicSize : rollHeight-Maui.Style.space.tiny

    signal picClicked(int index)

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false
    height: rollHeight
    width: parent.width

    Rectangle
    {
        anchors.fill: parent
        z:-1
        color: Kirigami.Theme.backgroundColor
        radius: unit * 3
        opacity: 0.8

        Kirigami.Separator
        {
            anchors
            {
                top: parent.rop
                left: parent.left
                right: parent.right
            }
//            color: Qt.darker(parent.color, 1.5)
        }

        Kirigami.Separator
        {
            anchors
            {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
//            color: Qt.darker(parent.color, 1.5)
        }
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
        spacing: Maui.Style.space.small

        focus: true
        interactive: true

        model: pixModel

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
