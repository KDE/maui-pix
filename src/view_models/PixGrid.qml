import QtQuick.Controls 2.2
import QtQuick 2.9

Pane
{
    id: gridPage

    /*props*/
    property int picSize : 150
    property int picSpacing: 20
    property int picRadius : 4

    property alias gridModel: gridModel
    property alias grid: grid

    /*signals*/
    signal picClicked(string url)

    width: 500
    height: 400

    Rectangle
    {
        anchors.fill: parent
        color: pix.altColor()
        z: -999
    }

    function clearGrid()
    {
        gridModel.clear()
    }

    PixHolder
    {
        visible: grid.count === 0
        message: "No pics..."
    }
    ListModel {id: gridModel}
    GridView
    {
        id: grid

        //        width: Math.min(model.count, Math.floor(parent.width/cellWidth))*cellWidth
        width: parent.width
        height: parent.height
//        anchors.horizontalCenter: parent.horizontalCenter

        cellWidth: picSize + picSpacing
        cellHeight: picSize + picSpacing

        highlightFollowsCurrentItem: false

        focus: true
        boundsBehavior: Flickable.StopAtBounds

        flickableDirection: Flickable.AutoFlickDirection

        snapMode: GridView.SnapToRow
        //        flow: GridView.FlowTopToBottom
        //        maximumFlickVelocity: albumSize*8

        model: gridModel

        highlight: Rectangle
        {
            id: highlight
            width: picSize
            height: picSize
            color: pix.hightlightColor()
            radius: 2
        }

        onWidthChanged:
        {
            var amount = parseInt(grid.width/(picSize + picSpacing),10)
            var leftSpace = parseInt(grid.width-(amount*(picSize + picSpacing)), 10)
            var size = parseInt((picSize + picSpacing)+(parseInt(leftSpace/amount, 10)), 10)

            size = size > picSize + picSpacing ? size : picSize + picSpacing

            grid.cellWidth = size
            //            grid.cellHeight = size
        }

        delegate: PixPic
        {
            id: delegate

            picSize : gridPage.picSize

            Connections
            {
                target: delegate
                onPicClicked:
                {
                    var url = grid.model.get(index).url
                    gridPage.picClicked(url)
                    grid.currentIndex = index
                }
            }
        }

        ScrollBar.vertical: ScrollBar{ visible: !pix.isMobile()}
    }

}
