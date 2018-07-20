import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.maui 1.0 as Maui

GridView
{
    id: folderGridRoot

    property int itemSize : iconSizes.large
    property int itemSpacing: itemSize * 0.5 + (isMobile ? space.big : space.large)

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

    delegate: Maui.IconDelegate
    {
        id: delegate
        folderSize : itemSize
        showTooltip: true

        width: cellWidth * 0.9
        height: cellHeight * 0.9

        showEmblem: false

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
