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
    property int itemSize : root.previewSize
    property int itemSpacing: Kirigami.Settings.isMobile ? Maui.Style.space.medium : Maui.Style.space.big
    property int itemRadius : Maui.Style.unit * 6

    property alias grid: grid
    property alias holder: grid.holder
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

    Maui.GridView
    {
        id: grid
        //        visible: !holder.visible
        anchors.fill: parent
        margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.big
        adaptContent: true
        itemSize: control.itemSize
        model: Maui.BaseModel
        {
            id: pixModel
            list:  GalleryList
            {
                id: pixList
            }
            sort: "title"
            sortOrder: Qt.AscendingOrder
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        enableLassoSelection: !Kirigami.Settings.hasTransientTouchInput

        holder.visible: count === 0
        holder.isMask: true
        holder.emojiSize: Maui.Style.iconSizes.huge

        onItemsSelected:
        {
            for(var i in indexes)
                PIX.selectItem(pixModel.get(indexes[i]))
        }

        onKeyPress:
        {
            const index = grid.currentIndex
            const item = grid.model.get(index)

            if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                if(selectionBox.contains(item.url))
                {
                    control.selectionBox.removeAtUri(item.url)
                }else
                {
                    grid.itemsSelected([index])
                }
            }
        }

        PixMenu
        {
            id: _picMenu
            index: grid.currentIndex
            model: pixModel
        }

        delegate: PixPic
        {
            id: delegate
            property int spacing : Kirigami.Settings.isMobile ? 2 : Maui.Style.space.big*1.2
            fit: fitPreviews
            labelsVisible: showLabels
            height: grid.cellHeight - spacing
            width: grid.cellWidth - spacing
            checkable: selectionMode

            isCurrentItem: (GridView.isCurrentItem || checked)
            checked: selectionBox.contains(model.url)

            Drag.keys: ["text/uri-list"]
            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.url)
                               } : {}

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
                if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
                {
                    grid.itemsSelected([index])
                }else if(Maui.Handy.singleClick)
                {
                    openPic(index)
                }
            }

            onDoubleClicked:
            {
                grid.currentIndex = index
                if(!Maui.Handy.singleClick && !selectionMode)
                {
                    openPic(index)
                }
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
            onToggled:
            {
                grid.currentIndex = index
                PIX.selectItem(pixModel.get(index))
            }
        }
    }
}

function filterSelectedItems(path)
{
    if(selectionBox && selectionBox.count > 0 && selectionBox.contains(path))
    {
        const uris = selectionBox.uris
        return uris.join("\n")
    }

    return path
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
