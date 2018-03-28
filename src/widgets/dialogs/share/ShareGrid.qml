import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

GridView
{
    property int gridSize : 64
    clip: true

    width: Math.min(model.count, Math.floor(parent.width/cellWidth))*cellWidth
    height: parent.height

    anchors.horizontalCenter: parent.horizontalCenter
    cellHeight: gridSize+(contentMargins*2)
    cellWidth: gridSize+(contentMargins*2)

    focus: true

    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.AutoFlickDirection
    snapMode: GridView.SnapToRow

    model: ListModel {id: gridModel}
    highlightFollowsCurrentItem: true
    highlight: Rectangle
    {
        width: cellWidth
        height: cellHeight
        color: highlightColor
        radius: 3
    }

    delegate: ShareDelegate
    {
        id: delegate
        iconSize : 32

        Connections
        {
            target: delegate
            onClicked:
            {
                currentIndex = index
                var obj = gridModel.get(index)
                pix.runApplication(obj.actionArgument, picUrl)
                shareDialog.close()
            }
        }
    }
}
