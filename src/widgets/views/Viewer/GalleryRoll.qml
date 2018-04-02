import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import "../../../view_models"

Item
{
    property alias rollList : rollList

    property int rollHeight : 48
    property int rollPicSize : 48

    signal picClicked(int index)

    height: rollHeight
    width: parent.width


    Rectangle
    {
        anchors.fill: parent
        z:-1
        color: Kirigami.Theme.complementaryBackgroundColor
        radius: 6
        opacity: 0.3
    }

    ListView
    {
        id: rollList
        width: parent.width* 0.9
        height: parent.height
        anchors.centerIn: parent

        orientation: ListView.Horizontal
        clip: true
        spacing: 4

        highlight: Rectangle
        {
            width: rollList.width
            height: rollList.currentItem.height
            color: highlightColor
        }

        focus: true
        interactive: true
        highlightFollowsCurrentItem: true

        model: ListModel{}

        delegate: PixPic
        {
            id: delegate
            picSize: rollPicSize
            picRadius: 6
            showLabel: false

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

    function populate(pics)
    {
        rollList.model.clear()
        if(pics.length > 0)
            for(var i in pics)
                rollList.model.append(pics[i])
    }


}
