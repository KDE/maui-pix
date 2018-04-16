import QtQuick.Controls 2.2
import QtQuick 2.9
import "../widgets/views/Viewer/Viewer.js" as VIEWER

PixPage
{
    id: gridPage

    /*props*/
    property int itemSize : isMobile ? 80 : 150
    property int itemSpacing: isMobile ? 10 : 50
    property int itemRadius : 4

    property alias grid: grid
    property alias holder: holder

    /*signals*/
    signal picClicked(int index)

    PixHolder
    {
        id: holder
        message: "<h2>No Pics!</h2><p>There's not images in here</p>"
        emoji: "qrc:/img/assets/face-hug.png"
        visible: grid.count === 0
    }

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
        width: parent.width
        height: parent.height

        cellWidth: itemSize + itemSpacing
        cellHeight: itemSize + itemSpacing


        focus: true
        boundsBehavior: Flickable.StopAtBounds

        flickableDirection: Flickable.AutoFlickDirection

        snapMode: GridView.SnapToRow
        //        flow: GridView.FlowTopToBottom
        //        maximumFlickVelocity: albumSize*8


        model: ListModel {id: gridModel}

        highlightMoveDuration: 0
        highlightFollowsCurrentItem: true
        highlight: Rectangle
        {
            width: itemSize + itemSpacing
            height: itemSize + itemSpacing
            color: highlightColor
            radius: 4
        }

        onWidthChanged:
        {
            var amount = parseInt(grid.width/(itemSize + itemSpacing),10)
            var leftSpace = parseInt(grid.width-(amount*(itemSize + itemSpacing)), 10)
            var size = parseInt((itemSize + itemSpacing)+(parseInt(leftSpace/amount, 10)), 10)

            size = size > itemSize + itemSpacing ? size : itemSize + itemSpacing

            grid.cellWidth = size
            //            grid.cellHeight = size
        }

        delegate: PixPic
        {
            id: delegate

            picSize : itemSize
            picRadius : itemRadius
            Connections
            {
                target: delegate
                onClicked:
                {
                    grid.currentIndex = index
                    if(isMobile)
                        openPic(index)
                }
                onDoubleClicked:
                {
                    //picClicked(index)
                    if(!isMobile)
                        openPic(index)
                }
                onPressAndHold: picMenu.show(gridModel.get(index).url)

                onRightClicked: picMenu.show(gridModel.get(index).url)
            }
        }

        ScrollBar.vertical: ScrollBar{ visible: true}
    }

    function clear()
    {
        gridModel.clear()
    }

    function openPic(index)
    {
        var data = []
        for(var i = 0; i < grid.model.count; i++)
            data.push(grid.model.get(i))

        VIEWER.open(data, index)
    }
}
