import QtQuick.Controls 2.10
import QtQuick 2.10
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import GalleryList 1.0

import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets/views/Pix.js" as PIX
import "../widgets"

Maui.Page
{
    id: control
    focus: true
    /*props*/
    property int itemSize : Kirigami.Settings.isMobile ? Maui.Style.iconSizes.huge * 1.5 : Maui.Style.iconSizes.enormous
    property int itemSpacing: Kirigami.Settings.isMobile ? Maui.Style.space.medium : Maui.Style.space.big
    property int itemRadius : Maui.Style.unit * 6

    property alias grid: grid
    property alias holder: holder
    property alias list : pixList
    property alias model: pixModel
    property alias menu : _picMenu
    property alias count: grid.count

    /*signals*/
    signal picClicked(int index)
    flickable: grid.flickable
    padding: 0
    showTitle: false
    headBar.leftSretch: false
    headBar.visible: list.count > 0
    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Search") + " " + count + " images"
        onAccepted: model.filter = text
        onCleared: model.filter = ""
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
                checked: pixModel.sort === "date"
                onTriggered: pixModel.sort = "date"
            }

            MenuItem
            {
                text: qsTr("Format")
                checkable: true
                checked: pixModel.sort === "format"
                onTriggered: pixModel.sort = "format"
            }

            MenuItem
            {
                text: qsTr("Size")
                checkable: true
                checked: pixModel.sort === "size"
                onTriggered: pixModel.sort = "size"
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
        }
    ]

    Maui.Holder
    {
        id: holder
        visible: grid.count === 0
        isMask: true
        emojiSize: Maui.Style.iconSizes.huge
    }

    PixMenu
    {
        id: _picMenu
        index: grid.currentIndex
        model: pixModel
    }

    Component
    {
        id: gridDelegate

        PixPic
        {
            id: delegate
            property int spacing : Kirigami.Settings.isMobile ? 2 : 10
            fit: fitPreviews
            labelsVisible: showLabels
            height: grid.cellHeight - spacing
            width: grid.cellWidth - spacing
            checkable: selectionMode

            isCurrentItem: (GridView.isCurrentItem || checked)
            checked: selectionBox.contains(model.url)

            Connections
            {
                target:selectionBox
                onUriRemoved:
                {
                    if(uri === model.url)
                        delegate.checked = false
                }

                onUriAdded:
                {
                    if(uri === model.url)
                        delegate.checked = true
                }

                onCleared: delegate.checked = false
            }

            Connections
            {
                target: delegate
                onClicked:
                {
                    grid.currentIndex = index
                    if(selectionMode)
                    {
                        PIX.selectItem(pixModel.get(index))
                    }else if(Kirigami.Settings.isMobile)
                    {
                        openPic(index)
                    }
                }

                onDoubleClicked:
                {
                    grid.currentIndex = index
                    if(!Kirigami.Settings.isMobile)
                    {
                        openPic(index)
                    }
                }

                onPressAndHold:
                {
                    grid.currentIndex = index
                     openPic(index)
                    _picMenu.popup()
                }

                onRightClicked:
                {
                    grid.currentIndex = index
                    _picMenu.popup()
                }
                onToggled:
                {
                    grid.currentIndex = index
                    PIX.selectItem(pixModel.get(index))
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
        visible: !holder.visible
        anchors.fill: parent
        padding: Maui.Style.space.medium
        adaptContent: true
        itemSize: control.itemSize

        model: pixModel
        delegate: gridDelegate
        enableLassoSelection: !Kirigami.Settings.hasTransientTouchInput

        onItemsSelected:
        {
            for(var i in indexes)
                PIX.selectItem(pixModel.get(indexes[i]))
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
