import QtQuick.Controls 2.9
import QtQuick.Layouts 1.3
import QtQuick 2.10

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
    property bool filterBar: false

    property alias grid: grid
    property alias holder: holder
    property alias list : pixList
    property alias model: pixModel
    property alias menu : _picMenu

    /*signals*/
    signal picClicked(int index)

    padding: 0
    showTitle: !_filterField.visible
    headBar.leftSretch: false

    headBar.middleContent: Maui.TextField
    {
        id: _filterField
        visible: grid.count && control.filterBar
        Layout.fillWidth: true
        placeholderText: qsTr("Filter...")
        onAccepted: pixModel.filter = text
        onCleared: pixModel.filter = ""
    }

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "item-select"
            onClicked: selectionMode = !selectionMode
            checkable: true
            checked: selectionMode
        },

        Maui.ToolButtonMenu
        {
            icon.name: "view-sort"
            MenuItem
            {
                text: qsTr("Title")
                checkable: true
                checked: pixModel.sort === "title"
                onTriggered: pixModel.sort = "title"
            }

            MenuItem
            {
                text: qsTr("Add date")
                checkable: true
                checked: pixModel.sort === "adddate"
                onTriggered: pixModel.sort = "adddate"
            }

            MenuItem
            {
                text: qsTr("Creation date")
                checkable: true
                checked: model.sort === "date"
                onTriggered: model.sort = "date"
            }

            MenuItem
            {
                text: qsTr("Format")
                checkable: true
                checked: model.sort === "format"
                onTriggered: model.sort = "format"
            }

            MenuItem
            {
                text: qsTr("Size")
                checkable: true
                checked: pixModel.sort === "size"
                onTriggered: pixModel.sort = "size"
            }

            MenuItem
            {
                text: qsTr("Favorites")
                checkable: true
                checked: pixModel.sort === "fav"
                onTriggered: pixModel.sort = "fav"
            }

            MenuSeparator {}

            MenuItem
            {
                text: qsTr("Ascending")
                onTriggered: pixModel.sortOrder = Qt.AscendingOrder
                checked: pixModel.sortOrder === Qt.AscendingOrder
                checkable: true
            }

            MenuItem
            {
                text: qsTr("Descending")
                onTriggered: pixModel.sortOrder = Qt.DescendingOrder
                checked: pixModel.sortOrder === Qt.DescendingOrder
                checkable: true
            }
        },

        ToolButton
        {
            icon.name: "view-filter"
            checkable: true
            checked: control.filterBar
            onClicked: control.filterBar = checked
        }
    ]

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
            showLabel: root.showLabels
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
        sort: "title"
        sortOrder: Qt.AscendingOrder
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
