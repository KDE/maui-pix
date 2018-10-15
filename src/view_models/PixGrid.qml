import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick 2.9
import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets/views/Pix.js" as PIX
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQml.Models 2.1

Maui.Page
{
    id: gridPage

    /*props*/
    property int itemSize : isMobile ? iconSizes.huge * 1.5 : iconSizes.enormous
    property int itemSpacing: isMobile ? space.medium : space.big
    property int itemRadius : Kirigami.Units.devicePixelRatio * 6
    property bool showLabels : pix.loadSettings("SHOW_LABELS", "GRID", !isMobile) === "true" ? true : false
    property bool fitPreviews : pix.loadSettings("PREVIEWS_FIT", "GRID", false) === "false" ?  false : true
    property alias model: gridModel
    property alias grid: grid
    property alias holder: holder

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
            text: qsTr("Sort...")
        }

        Maui.MenuItem
        {
            text: qsTr(fitPreviews ?  "Crop previews" : "Fit previews")
            onTriggered:
            {
                fitPreviews = !fitPreviews
                //model = gridModel

                pix.saveSettings("PREVIEWS_FIT", fitPreviews, "GRID")
            }
        }

        Maui.MenuItem
        {
            text: qsTr(showLabels ? "Hide labels" : "Show labels")
            onTriggered:
            {
                showLabels = !showLabels
//                model = gridModel

                pix.saveSettings("SHOW_LABELS", showLabels, "GRID")
            }
        }
    }

    headBarTitle: gridModel.count+" "+qsTr("images")

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
        },
        Maui.ToolButton
        {
            iconName: "image-frame"
            onClicked: fitPreviews = !fitPreviews
            iconColor: !fitPreviews ? highlightColor : textColor
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


    ListModel {id: gridModel}
    DelegateModel
    {
        id: displayDelegateModel
        delegate: gridDelegate
        model: gridModel

        groups: [
            DelegateModelGroup {
                includeByDefault: true
                name: "label"
            }
        ]
        filterOnGroup: "label"
        //        Component.onCompleted: {
        //                var rowCount = folderModel.count;
        //                items.remove(0,rowCount);
        //                for( var i = 0;i < rowCount;i++ ) {
        //                    var entry = folderModel.get(i);
        //                    if(entry.role_display !== undefined) {
        //                        items.insert(entry, "displayField");
        //                    }
        //                }
        //            }
    }
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
                        PIX.selectItem(gridModel.get(index))
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
                    var item = gridModel.get(index)
                    selectionBox.append({
                                            path: item.url,
                                            thumbnail: item.url,
                                            mime: "image",
                                            tooltip: item.title,
                                            label: item.title

                                        })
                }
            }
        }
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

        model: displayDelegateModel
    }

    function clear()
    {
        gridModel.clear()
    }

    function openPic(index)
    {
        VIEWER.open(model, index)
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
