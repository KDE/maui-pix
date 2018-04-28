import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

GridView
{
    id: albumsGridRoot

    property int itemSize : iconSizes.huge
    property int itemSpacing: itemSize * 0.5 + (isMobile ? space.big : space.large)

    property string currentAlbum : ""

    signal albumClicked(int index)

    clip: true

    width: parent.width
    height: parent.height

    cellWidth: itemSize + itemSpacing
    cellHeight: itemSize + itemSpacing

    focus: true

    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.AutoFlickDirection
    snapMode: GridView.SnapToRow

    model: ListModel
    {
        id: gridModel
    }

    highlightMoveDuration: 0

    delegate: AlbumDelegate
    {
        id: delegate
        albumSize : itemSize

        width: cellWidth
        height: cellHeight * 0.9

        Connections
        {
            target: delegate
            onClicked:
            {
                albumsGridRoot.currentIndex = index
                albumClicked(index)
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
    }

    ScrollBar.vertical: ScrollBar{ visible: true}
}
