import QtQuick.Controls 2.2
import QtQuick 2.9

PixPage
{
    id: gridPage

    /*props*/
    property int picSize : 150
    property int picSpacing: 50
    property int picRadius : 4

    property alias grid: grid

    /*signals*/
    signal picClicked(int index)

    headerbarTitle: gridModel.count+" "+qsTr("images")

    headerBarRight: [
        PixButton
        {
            id: menuBtn
            iconName: "overflow-menu"
        }
    ]

    content: GridView
    {
        id: grid
        clip: true
        //        width: Math.min(model.count, Math.floor(parent.width/cellWidth))*cellWidth
        width: parent.width
        height: parent.height
        //        anchors.horizontalCenter: parent.horizontalCenter

        cellWidth: picSize + picSpacing
        cellHeight: picSize + picSpacing


        focus: true
        boundsBehavior: Flickable.StopAtBounds

        flickableDirection: Flickable.AutoFlickDirection

        snapMode: GridView.SnapToRow
        //        flow: GridView.FlowTopToBottom
        //        maximumFlickVelocity: albumSize*8


        model: ListModel {id: gridModel}


        highlightFollowsCurrentItem: true
        highlight: Rectangle
        {
            width: picSize + picSpacing
            height: picSize + picSpacing
            color: highlightColor
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
                onClicked:
                {
                    picClicked(index)
                    grid.currentIndex = index
                }
            }
        }

        ScrollBar.vertical: ScrollBar{ visible: !isMobile}
    }

    function clearGrid()
    {
        gridModel.clear()
    }

}
