import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3


GridView
{
    id: folderGridRoot

    property int itemSize : iconSizes.large
    property int itemSpacing: itemSize*0.5 + space.small

    signal folderClicked(int index)

    clip: true

    width: parent.width
    height: parent.height

    cellWidth: itemSize + itemSpacing
    cellHeight: itemSize + itemSpacing

    focus: true

    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.AutoFlickDirection
    snapMode: GridView.SnapToRow

    model: ListModel {id: gridModel}
    highlightFollowsCurrentItem: true

    delegate: FoldersDelegate
    {
        id: delegate
        folderSize : itemSize

        width: cellWidth
        height: cellHeight

        Connections
        {
            target: delegate
            onClicked:
            {
                folderGridRoot.currentIndex = index
                folderClicked(index)
            }
        }
    }

    onWidthChanged:
    {
        var amount = parseInt(width/(itemSize + itemSpacing),10)
        var leftSpace = parseInt(width-(amount*(itemSize + itemSpacing)), 10)
        var size = parseInt((itemSize + itemSpacing)+(parseInt(leftSpace/amount, 10)), 10)

        size = size > itemSize + itemSpacing ? size : itemSize + itemSpacing

        cellWidth = size
        //            grid.cellHeight = size
    }

    ScrollBar.vertical: ScrollBar{ visible: true}

}
