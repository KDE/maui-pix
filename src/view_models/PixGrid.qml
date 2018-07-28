import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick 2.9
import "../widgets/views/Viewer/Viewer.js" as VIEWER
import org.kde.kirigami 2.0 as Kirigami
import org.kde.maui 1.0 as Maui

Maui.Page
{
    id: gridPage

    /*props*/
    property int itemSize : isMobile ? iconSizes.huge * 1.5 : iconSizes.enormous
    property int itemSpacing: isMobile ? space.medium : space.big
    property int itemRadius : Kirigami.Units.devicePixelRatio * 6
    property bool showLabels : pix.loadSettings("SHOW_LABELS", "GRID", !isMobile) === "true" ? true : false

    property alias grid: grid
    property alias holder: holder

    /*signals*/
    signal picClicked(int index)

    Maui.Holder
    {
        id: holder        
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
                grid.model = gridModel

                pix.saveSettings("PREVIEWS_FIT", fitPreviews, "GRID")
            }
        }

        MenuItem
        {
            text: qsTr(showLabels ? "Hide labels" : "Show labels")
            onTriggered:
            {
                showLabels = !showLabels
                grid.model = gridModel
                pix.saveSettings("SHOW_LABELS", showLabels, "GRID")
            }
        }
    }

    headBarTitle: gridModel.count+" "+qsTr("images")

    headBar.rightContent: Maui.ToolButton
    {
        id: menuBtn
        iconName: "overflow-menu"
        onClicked: isMobile? gridMenu.open() : gridMenu.popup()
    }

    GridView
    {
        id: grid
        width: parent.width
        height: parent.height

        clip: true

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
            fit: fitPreviews
            showLabel: gridPage.showLabels
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

                onPressAndHold:
                {
                    grid.currentIndex = index
                    picMenu.show(gridModel.get(index).url)
                }

                onRightClicked:
                {
                    grid.currentIndex = index
                    picMenu.show(gridModel.get(index).url)
                }
                onEmblemClicked:
                {
                    grid.currentIndex = index
                    selectionBox.append(gridModel.get(index))
                }
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
        VIEWER.open(grid.model, index)
    }
}
