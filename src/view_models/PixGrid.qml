import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick 2.9
import "../widgets/views/Viewer/Viewer.js" as VIEWER

PixPage
{
    id: gridPage

    /*props*/
    property int itemSize : isMobile ? iconSizes.huge : iconSizes.enormous
    property int itemSpacing: isMobile ? space.medium : space.big
    property int itemRadius : itemSize*0.05

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

    PixMenu
    {
        id: gridMenu

        MenuItem
        {
            text: qsTr(selectionBox.selectionMode ? "Selection OFF" : "Selection ON")
            onTriggered: selectionBox.selectionMode  = !selectionBox.selectionMode
        }

        MenuItem
        {
            text: qsTr(selectionBox.selectionMode ? "Select all" : "UnSelect all")
        }

        MenuItem
        {
            text: qsTr("Sort...")
        }

        MenuItem
        {
            text: qsTr(fitPreviews ?  "Crop previews" : "Fit previews")
            onTriggered:
            {
                fitPreviews = !fitPreviews

                pix.saveSettings("PREVIEWS_FIT", fitPreviews, "PIX")
            }
        }
    }

    headerbarTitle: gridModel.count+" "+qsTr("images")

    headerBarRight: [
        PixButton
        {
            id: menuBtn
            iconName: "overflow-menu"
            onClicked: isMobile? gridMenu.open() : gridMenu.popup()
        }
    ]

    content: GridView
    {
        id: grid
        width: parent.width
        height: parent.height

        clip: true

        Layout.fillWidth: true
        Layout.fillHeight: true

        cellWidth: itemSize + itemSpacing
        cellHeight: itemSize + itemSpacing


        focus: true
        boundsBehavior: Flickable.StopAtBounds

        flickableDirection: Flickable.AutoFlickDirection

        snapMode: GridView.SnapToRow
        //        flow: GridView.FlowTopToBottom
        //        maximumFlickVelocity: albumSize*8


        model: ListModel {id: gridModel}

        //        highlightMoveDuration: 0
        //        highlightFollowsCurrentItem: true
        //        highlight: Rectangle
        //        {
        //            width: itemSize + itemSpacing
        //            height: itemSize + itemSpacing
        //            color: highlightColor
        //            radius: 4
        //        }

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

            height: grid.cellHeight * 0.9
            width: grid.cellWidth * 0.8

            Connections
            {
                target: delegate
                onClicked:
                {
                    grid.currentIndex = index

                    if(selectionBox.selectionMode)
                        selectionBox.append(gridModel.get(index))
                    else if(isMobile)
                        openPic(index)
                }
                onDoubleClicked:
                {
                    //picClicked(index)
                    if(!isMobile)
                        openPic(index)
                    //                    else
                    //                        selectionBox.append(gridModel.get(index))

                }

                onPressAndHold: picMenu.show(gridModel.get(index).url)

                onRightClicked: picMenu.show(gridModel.get(index).url)
                onEmblemClicked: selectionBox.append(gridModel.get(index))
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
