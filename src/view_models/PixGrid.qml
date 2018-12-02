import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick 2.9
import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets/views/Pix.js" as PIX
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import PIX 1.0
import PixModel 1.0
import GalleryList 1.0
import FMList 1.0

import "../widgets"

Maui.Page
{
    id: gridPage

    /*props*/
    property int itemSize : isMobile ? iconSizes.huge * 1.5 : iconSizes.enormous
    property int itemSpacing: isMobile ? space.medium : space.big
    property int itemRadius : Kirigami.Units.devicePixelRatio * 6
    property bool showLabels : Maui.FM.loadSettings("SHOW_LABELS", "GRID", !isMobile) === "true" ? true : false
    property bool fitPreviews : Maui.FM.loadSettings("PREVIEWS_FIT", "GRID", false) === "false" ?  false : true

    property alias grid: grid
    property alias holder: holder
    property alias list : pixList

    /*signals*/
    signal picClicked(int index)
    floatingBar: true
    footBarOverlap: true

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
            text: qsTr(selectionMode ? "Selection OFF" : "Selection ON")
            onTriggered: selectionMode  = !selectionMode
        }

        Maui.MenuItem
        {
            text: qsTr(selectionMode ? "Select all" : "UnSelect all")
        }

        Maui.MenuItem
        {
            text: qsTr(fitPreviews ?  "Crop previews" : "Fit previews")
            onTriggered:
            {
                fitPreviews = !fitPreviews
                Maui.FM.saveSettings("PREVIEWS_FIT", fitPreviews, "GRID")
            }
        }

        Maui.MenuItem
        {
            text: qsTr(showLabels ? "Hide labels" : "Show labels")
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
            iconName: "edit-select"
            onClicked: selectionMode = !selectionMode
            iconColor: selectionMode ? highlightColor : textColor

        },
        Maui.ToolButton
        {
            id: menuBtn
            iconName: "overflow-menu"
            onClicked: isMobile? gridMenu.open() : gridMenu.popup()
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
                    checked: pixList.sortBy === FMList.TITLE
                    onTriggered: pixList.sortBy = FMList.TITLE
                }

                Maui.MenuItem
                {
                    text: qsTr("Add date")
                    checkable: true
                    checked: pixList.sortBy === FMList.ADDDATE
                    onTriggered: pixList.sortBy = FMList.ADDDATE
                }

                Maui.MenuItem
                {
                    text: qsTr("Creation date")
                    checkable: true
                    checked: pixList.sortBy === FMList.DATE
                    onTriggered: pixList.sortBy = FMList.DATE
                }

                Maui.MenuItem
                {
                    text: qsTr("Place")
                    checkable: true
                    checked: pixList.sortBy === FMList.PLACE
                    onTriggered: pixList.sortBy = FMList.PLACE
                }

                Maui.MenuItem
                {
                    text: qsTr("Format")
                    checkable: true
                    checked: pixList.sortBy === FMList.FORMAT
                    onTriggered: pixList.sortBy = FMList.FORMAT
                }

                Maui.MenuItem
                {
                    text: qsTr("Size")
                    checkable: true
                    checked: pixList.sortBy === FMList.SIZE
                    onTriggered: pixList.sortBy = FMList.SIZE
                }
            }
        },
        Maui.ToolButton
        {
            iconName: "image-frame"
            onClicked: fitPreviews = !fitPreviews
            iconColor: !fitPreviews ? highlightColor : textColor
        },
        Maui.ToolButton
        {
            iconName: "filename-space-amarok"
            onClicked: showLabels = !showLabels
            iconColor: showLabels ? highlightColor : textColor
        }
    ]

    footBar.colorScheme.backgroundColor: accentColor
    footBar.colorScheme.textColor: altColorText
    footBar.visible: !holder.visible
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
                    //picClicked(index)
                    if(!isMobile)
                        openPic(index)
                    //                    else
                    //                        selectionBox.append(gridModel.get(index))

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
