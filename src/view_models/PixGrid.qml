import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick 2.9

import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import PixModel 1.0
import GalleryList 1.0
import FMList 1.0

import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets/views/Pix.js" as PIX
import "../widgets"

Maui.Page
{
    id: gridPage

    /*props*/
    property int itemSize : isMobile ? iconSizes.huge * 1.5 : iconSizes.enormous
    property int itemSpacing: isMobile ? space.medium : space.big
    property int itemRadius : unit * 6
    property bool showLabels : Maui.FM.loadSettings("SHOW_LABELS", "GRID", !isMobile) === "true" ? true : false
    property bool fitPreviews : Maui.FM.loadSettings("PREVIEWS_FIT", "GRID", false) === "false" ?  false : true

    property alias grid: grid
    property alias holder: holder
    property alias list : pixList
    property alias model: pixModel
    property alias menu : _picMenu

    /*signals*/
    signal picClicked(int index)
    floatingBar: true
    footBarOverlap: true
    headBar.drawBorder: false

    Maui.Holder
    {
        id: holder
        visible: grid.count === 0
    }

    Maui.Menu
    {
        id: gridMenu

        Maui.MenuItem
        {
            checkable: true
            checked: fitPreviews
            text: qsTr( "Fit previews")
            onTriggered:
            {
                fitPreviews = !fitPreviews
                Maui.FM.saveSettings("PREVIEWS_FIT", fitPreviews, "GRID")
            }
        }

        Maui.MenuItem
        {
            checkable: true
            checked: showLabels
            text: qsTr("Show labels")
            onTriggered:
            {
                showLabels = !showLabels
                Maui.FM.saveSettings("SHOW_LABELS", showLabels, "GRID")
            }
        }
    }

    PixMenu
    {
        id: _picMenu
        index: grid.currentIndex
    }

    headBarTitle: grid.count+" "+qsTr("images")

    headBar.rightContent:[
        Maui.ToolButton
        {
            iconName: "item-select"
            onClicked: selectionMode = !selectionMode
            iconColor: selectionMode ? highlightColor : textColor

        },
        Maui.ToolButton
        {
            id: menuBtn
            iconName: "overflow-menu"
            onClicked: gridMenu.popup()
        }
    ]

    headBar.leftContent: [
        Maui.ToolButton
        {
            iconName: "view-sort"
            onClicked: sortMenu.popup()

            Maui.Menu
            {
                id: sortMenu

                Maui.MenuItem
                {
                    text: qsTr("Title")
                    checkable: true
                    checked: pixList.sortBy === GalleryList.TITLE
                    onTriggered: pixList.sortBy = GalleryList.TITLE
                }

                Maui.MenuItem
                {
                    text: qsTr("Add date")
                    checkable: true
                    checked: pixList.sortBy === GalleryList.ADDDATE
                    onTriggered: pixList.sortBy = GalleryList.ADDDATE
                }

                Maui.MenuItem
                {
                    text: qsTr("Creation date")
                    checkable: true
                    checked: pixList.sortBy === GalleryList.DATE
                    onTriggered: pixList.sortBy = GalleryList.DATE
                }

//                Maui.MenuItem
//                {
//                    text: qsTr("Place")
//                    checkable: true
//                    checked: pixList.sortBy === FMList.PLACE
//                    onTriggered: pixList.sortBy = FMList.PLACE
//                }

                Maui.MenuItem
                {
                    text: qsTr("Format")
                    checkable: true
                    checked: pixList.sortBy === GalleryList.FORMAT
                    onTriggered: pixList.sortBy = GalleryList.FORMAT
                }

                Maui.MenuItem
                {
                    text: qsTr("Size")
                    checkable: true
                    checked: pixList.sortBy === GalleryList.SIZE
                    onTriggered: pixList.sortBy = GalleryList.SIZE
                }

                Maui.MenuItem
                {
                    text: qsTr("Favorites")
                    checkable: true
                    checked: pixList.sortBy === GalleryList.FAV
                    onTriggered: pixList.sortBy = GalleryList.FAV
                }
            }
        }
    ]

    footBar.colorScheme.backgroundColor: accentColor
    footBar.colorScheme.textColor: altColorText
    footBar.visible: false
    footBar.middleContent: [
        Maui.ToolButton
        {
            iconName: "zoom-in"
            iconColor: altColorText
            onClicked: zoomIn()
        },
        Maui.ToolButton
        {
            iconName: "zoom-out"
            iconColor: altColorText
            onClicked: zoomOut()
        }
    ]

    Component
    {
        id: gridDelegate

        PixPic
        {
            id: delegate
            picSize : itemSize
            picRadius : itemRadius
            fit: fitPreviews
            showLabel: gridPage.showLabels
            height: grid.cellHeight * 0.9
            width: grid.cellWidth * 0.8
            showEmblem: selectionMode

            Connections
            {
                target: delegate
                onClicked:
                {
                    grid.currentIndex = index
                    if(selectionMode)
                        PIX.selectItem(pixList.get(index))
                    else if(isMobile)
                        openPic(index)
                }

                onDoubleClicked:
                {
                    grid.currentIndex = index
                    if(!isMobile)
                        openPic(index)
                }

                onPressAndHold:
                {
                    grid.currentIndex = index
                    _picMenu.popup()
                }

                onRightClicked:
                {
                    grid.currentIndex = index
                    _picMenu.popup()
                }
                onEmblemClicked:
                {
                    grid.currentIndex = index
                    var item = pixList.get(index)
                    PIX.selectItem(item)
                }
            }
        }
    }

    PixModel
    {
        id: pixModel
        list: pixList
    }

    GalleryList
    {
        id: pixList
    }

    Maui.GridView
    {
        id: grid
        height: parent.height
        width: parent.width
        adaptContent: true
        itemSize: gridPage.itemSize
        spacing: itemSpacing
        cellWidth: itemSize
        cellHeight: itemSize

        //        highlightMoveDuration: 0
        //        highlightFollowsCurrentItem: true
        //        highlight: Rectangle
        //        {
        //            width: itemSize + itemSpacing
        //            height: itemSize + itemSpacing
        //            color: highlightColor
        //            radius: 4
        //        }

        model: pixModel
        delegate: gridDelegate
    }

    function openPic(index)
    {
        VIEWER.open(pixList, index)
    }

    function zoomIn()
    {
        itemSize = itemSize + 20
        refreshGrid()
    }

    function zoomOut()
    {
        itemSize = itemSize - 20
        refreshGrid()
    }

    function refreshGrid()
    {
        grid.adaptGrid()
    }
}
