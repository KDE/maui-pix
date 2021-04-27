import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.pix 1.0

import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets/views/Pix.js" as PIX
import "../widgets"

Maui.AltBrowser
{
    id: control
    focus: true
    viewType: Maui.AltBrowser.ViewType.Grid
    property int itemSize : browserSettings.previewSize

    property alias list : pixList
    property alias menu : _picMenu
    property alias count: pixList.count

    /*signals*/
    signal picClicked(int index)
    showTitle: false

    enableLassoSelection: true
    //    selectionMode: root.selectionMode
    gridView.itemSize : control.itemSize
    gridView.itemHeight: browserSettings.showLabels ? control.itemSize * 1.5 : control.itemSize

    listView.section.criteria: model.sort === "title" ?  ViewSection.FirstCharacter : ViewSection.FullString
    listView.section.property: model.sort
    listView.section.delegate: Maui.ListItemTemplate
    {
        id: delegate
        width: ListView.view.width
        height: Maui.Style.toolBarHeightAlt
        label1.text: model.sort === "date" || model.sort === "modified" ? Qt.formatDateTime(new Date(section), "d MMM yyyy") : (model.sort === "size" ? Maui.Handy.formatSize(section)  : section)
        label1.font.pointSize: Maui.Style.fontSizes.big
    }

    holder.visible: count === 0
    holder.emojiSize: Maui.Style.iconSizes.huge

    headBar.visible: true
    headBar.middleContent: Maui.TextField
    {
        enabled: list.count > 0
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Search") + " " + count + " images"
        onAccepted: model.filter = text
        onCleared: model.filter = ""
    }

    headBar.leftContent: ToolButton
    {
        enabled: list.count > 0
        icon.name: control.viewType === Maui.AltBrowser.ViewType.List ? "view-list-icons" : "view-list-details"

        onClicked:
        {
            control.viewType =  control.viewType === Maui.AltBrowser.ViewType.List ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List
        }
    }

    model: Maui.BaseModel
    {
        id: pixModel
        list: GalleryList
        {
            id: pixList
            autoReload: browserSettings.autoReload
        }

        sort: browserSettings.sortBy
        sortOrder: browserSettings.sortOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    property string typingQuery

    Maui.Chip
    {
        z: control.z + 99999
        Kirigami.Theme.colorSet:Kirigami.Theme.Complementary
        visible: _typingTimer.running
        label.text: typingQuery
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        showCloseButton: false
        anchors.margins: Maui.Style.space.medium
    }

    Timer
    {
        id: _typingTimer
        interval: 250
        onTriggered:
        {
            const index = pixList.indexOfName(typingQuery)
            if(index > -1)
            {
                control.currentIndex = index
            }

            typingQuery = ""
        }
    }

    Connections
    {
        target: control.currentView
        ignoreUnknownSignals: true

        function onItemsSelected(indexes)
        {
            for(var i in indexes)
                PIX.selectItem(pixModel.get(indexes[i]))
        }

        function onKeyPress(event)
        {
            const index = control.currentIndex
            const item = control.model.get(index)

            var pat = /^([a-zA-Z0-9 _-]+)$/
            if(event.count === 1 && pat.test(event.text))
            {
                typingQuery += event.text
                _typingTimer.restart()
            }

            if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                control.currentView.itemsSelected([index])
            }

            if(event.key === Qt.Key_Space)
            {
                getFileInfo(item.url)
            }

            if(event.key === Qt.Key_Return)
            {
                openPic(index)
            }
        }
    }

    PixMenu
    {
        id: _picMenu
        index: control.currentIndex
        model: pixModel
    }

    listDelegate: PixPicList
    {
        id: _listDelegate
        height: Maui.Style.rowHeight * 2
        width: ListView.view.width

        isCurrentItem: (ListView.isCurrentItem || checked)
        checked: selectionBox.contains(model.url)
        checkable: root.selectionMode
        Drag.keys: ["text/uri-list"]
        Drag.mimeData: Drag.active ? {"text/uri-list": control.filterSelectedItems(model.url)} : {}

    onClicked:
    {
        control.currentIndex = index
        if(root.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
        {
            control.currentView.itemsSelected([index])
        }else if(Maui.Handy.singleClick)
        {
            openPic(index)
        }
    }

    onDoubleClicked:
    {
        control.currentIndex = index
        if(!Maui.Handy.singleClick && !root.selectionMode)
        {
            openPic(index)
        }
    }

    onPressAndHold:
    {
        control.currentIndex = index
        _picMenu.open()
    }

    onRightClicked:
    {
        control.currentIndex = index
        _picMenu.open()
    }
    onToggled:
    {
        control.currentIndex = index
        PIX.selectItem(pixModel.get(index))
    }

    Connections
    {
        target: selectionBox
        ignoreUnknownSignals: true

        function onUriRemoved(uri)
        {
            if(uri === model.url)
            {
                _listDelegate.checked = false
            }
        }

        function onUriAdded(uri)
        {
            if(uri === model.url)
            {
                _listDelegate.checked = true
            }
        }

        function onCleared()
        {
            _listDelegate.checked = false
        }
    }
}

gridDelegate: Item
{
    height: control.gridView.cellHeight
    width: control.gridView.cellWidth
    property bool isCurrentItem: GridView.isCurrentItem

    PixPic
    {
        id: _gridDelegate
        anchors.fill: parent
        anchors.margins: !root.isWide ? Maui.Style.space.tiny : Maui.Style.space.big

        fit: browserSettings.fitPreviews
        showLabel: browserSettings.showLabels
        checkable: root.selectionMode
        template.imageBorder: root.isWide
        radius: !root.isWide  ? 0 : Maui.Style.radiusV
        isCurrentItem: parent.isCurrentItem
        checked: selectionBox.contains(model.url)

        Drag.keys: ["text/uri-list"]
        Drag.mimeData: Drag.active ? { "text/uri-list": control.filterSelectedItems(model.url) } : {}

        onClicked:
        {
            control.currentIndex = index
            if(root.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                control.currentView.itemsSelected([index])
            }else if(Maui.Handy.singleClick)
            {
                openPic(index)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !root.selectionMode)
            {
                openPic(index)
            }
        }

        onPressAndHold:
        {
            control.currentIndex = index
            _picMenu.open()
        }

        onRightClicked:
        {
            control.currentIndex = index
            _picMenu.open()
        }

        onToggled:
        {
            control.currentIndex = index
            PIX.selectItem(pixModel.get(index))
        }
    }


    Connections
    {
        target: selectionBox
        ignoreUnknownSignals: true

        function onUriRemoved(uri)
        {
            if(uri === model.url)
            {
                _gridDelegate.checked = false
            }
        }

        function onUriAdded(uri)
        {
            if(uri === model.url)
            {
                _gridDelegate.checked = true
            }
        }

        function onCleared()
        {
            _gridDelegate.checked = false
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
    //    grid.adaptGrid()
}
}
