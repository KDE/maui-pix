import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick 2.9

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import GalleryList 1.0

import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets/views/Pix.js" as PIX
import "../widgets"

Maui.Page
{
    id: control

    /*props*/
    property int itemSize : Kirigami.Settings.isMobile ? Maui.Style.iconSizes.huge * 1.5 : Maui.Style.iconSizes.enormous
    property int itemSpacing: Kirigami.Settings.isMobile ? Maui.Style.space.medium : Maui.Style.space.big
    property int itemRadius : Maui.Style.unit * 6
    property bool showLabels : Maui.FM.loadSettings("SHOW_LABELS", "GRID", !Kirigami.Settings.isMobile) === "true" ? true : false
    property bool fitPreviews : Maui.FM.loadSettings("PREVIEWS_FIT", "GRID", false) === "false" ?  false : true

    property alias grid: grid
    property alias holder: holder
    property alias list : pixList
    property alias model: pixModel
    property alias menu : _picMenu

    /*signals*/
    signal picClicked(int index)

    padding: 0

    Maui.Holder
    {
        id: holder
        visible: grid.count === 0
    }

    PixMenu
    {
        id: _picMenu
        index: grid.currentIndex
    }

    Component
    {
        id: gridDelegate

        PixPic
        {
            id: delegate
            picRadius : itemRadius
            fit: fitPreviews
            showLabel: control.showLabels
            height: grid.cellHeight
            width: grid.cellWidth
            showEmblem: selectionMode
            isCurrentItem: GridView.isCurrentItem
            selected: selectionBox.contains(model.url)

            Connections
            {
                target:selectionBox
                onUriRemoved:
                {
                    if(uri === model.url)
                        delegate.selected = false
                }

                onUriAdded:
                {
                    if(uri === model.url)
                        delegate.selected = true
                }

                onCleared: delegate.selected = false
            }

            Connections
            {
                target: delegate
                onClicked:
                {
                    grid.currentIndex = index
                    if(selectionMode)
                        PIX.selectItem(pixModel.get(index))
                    else if(Kirigami.Settings.isMobile)
                        openPic(index)
                }

                onDoubleClicked:
                {
                    grid.currentIndex = index
                    if(!Kirigami.Settings.isMobile)
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
                    var item = pixModel.get(index)
                    PIX.selectItem(item)
                }
            }
        }
    }

    Maui.BaseModel
    {
        id: pixModel
        list: pixList
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
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
        itemSize: control.itemSize

        model: pixModel
        delegate: gridDelegate

        gridView.header: Maui.ToolBar
        {
            width: parent.width
            leftSretch: false

            middleContent: Maui.TextField
            {
                id: _filterField
                Layout.fillWidth: true
                placeholderText: qsTr("Filter...")
                onAccepted: pixModel.filter = text
                onCleared: pixModel.filter = ""
            }

            rightContent: [
                ToolButton
                {
                    icon.name: "item-select"
                    onClicked: selectionMode = !selectionMode
                    text: qsTr("Select")
                    checkable: true
                    checked: selectionMode
                },

                Maui.ToolButtonMenu
                {
                    icon.name: "view-sort"
                    text: qsTr("Sort")

                    MenuItem
                    {
                        text: qsTr("Title")
                        checkable: true
                        checked: pixList.sortBy === GalleryList.TITLE
                        onTriggered: pixList.sortBy = GalleryList.TITLE
                    }

                    MenuItem
                    {
                        text: qsTr("Add date")
                        checkable: true
                        checked: pixList.sortBy === GalleryList.ADDDATE
                        onTriggered: pixList.sortBy = GalleryList.ADDDATE
                    }

                    MenuItem
                    {
                        text: qsTr("Creation date")
                        checkable: true
                        checked: pixList.sortBy === GalleryList.DATE
                        onTriggered: pixList.sortBy = GalleryList.DATE
                    }

                    MenuItem
                    {
                        text: qsTr("Format")
                        checkable: true
                        checked: pixList.sortBy === GalleryList.FORMAT
                        onTriggered: pixList.sortBy = GalleryList.FORMAT
                    }

                    MenuItem
                    {
                        text: qsTr("Size")
                        checkable: true
                        checked: pixList.sortBy === GalleryList.SIZE
                        onTriggered: pixList.sortBy = GalleryList.SIZE
                    }

                    MenuItem
                    {
                        text: qsTr("Favorites")
                        checkable: true
                        checked: pixList.sortBy === GalleryList.FAV
                        onTriggered: pixList.sortBy = GalleryList.FAV
                    }
                },
                Maui.ToolButtonMenu
                {
                    icon.name: "overflow-menu"

                    MenuItem
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

                    MenuItem
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

            ]
        }
    }

    function openPic(index)
    {
        VIEWER.open(pixModel, index)
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
