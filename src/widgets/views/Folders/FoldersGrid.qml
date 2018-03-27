import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

GridView
{
    id: folderGridRoot
    property int gridSize : 64
    clip: true
    height: parent.height
    width: parent.width
    cellHeight: gridSize+contentMargins
    cellWidth: gridSize+contentMargins

    focus: true

    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.AutoFlickDirection
    snapMode: GridView.SnapToRow

    model: ListModel {id: gridModel}
    highlightFollowsCurrentItem: true

    delegate: FoldersDelegate
    {
        folderSize : 32
    }


}
