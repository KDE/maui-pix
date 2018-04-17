import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3


GridView
{
    id: folderGridRoot
    property int gridSize : 48
    signal folderClicked(int index)

    clip: true

    width: parent.width
    height: parent.height

    cellHeight: gridSize*2
    cellWidth: gridSize*2

    focus: true

    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.AutoFlickDirection
    snapMode: GridView.SnapToRow

    model: ListModel {id: gridModel}
    highlightFollowsCurrentItem: true

    delegate: FoldersDelegate
    {
        id: delegate
        folderSize : 32

        Connections
        {
            target: delegate
            onClicked: folderClicked(index)
        }
    }

    onWidthChanged:
    {
        var amount = parseInt(width/(gridSize*2),10)
        var leftSpace = parseInt(width-(amount*(gridSize*2)), 10)
        var size = parseInt((gridSize*2)+(parseInt(leftSpace/amount, 10)), 10)

        size = size > gridSize*2 ? size : gridSize*2

        cellWidth = size
        //            grid.cellHeight = size
    }

    ScrollBar.vertical: ScrollBar{ visible: true}

}
