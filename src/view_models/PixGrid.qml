import QtQuick 2.14

import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

import org.maui.pix 1.0

import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets"

Maui.Page
{
    id: control

    Maui.Theme.inherit: false
    Maui.Theme.colorGroup: Maui.Theme.View

    property int itemSize : browserSettings.previewSize

    readonly property alias listModel : pixModel
    readonly property alias menu : _picMenu
    readonly property alias holder : _gridView.holder
    readonly property alias model: _gridView.model
    readonly property alias gridView: _gridView
    readonly property alias count: _gridView.count

    property alias currentIndex: _gridView.currentIndex
    property string typingQuery

    property GalleryList list : GalleryList
    {
        autoReload: browserSettings.autoReload
    }

    flickable: _gridView.flickable
    showTitle: false

    property Component searchFieldComponent : Maui.SearchField
    {
        enabled: control.list.count > 0
        text: pixModel.filters.join(",")
        placeholderText: i18np("Search image", "Search %1 images", control.list.count)
        onAccepted:
        {
            if(_ocrOption.checked)
            {
                control.list.scanImagesText()
            }

            if(text.includes(","))
            {
                model.filters = text.split(",")
            }else
            {
                model.filter = text
            }
        }

        onCleared: model.clearFilters()

        rightContent: Maui.ToolButtonMenu
        {
            icon.name: "view-filter"
            visible: Maui.Handy.isLinux

            MenuItem
            {
                id: _ocrOption
                text: i18n("Image Text (OCR)")
                checkable: true
            }
        }
    }

    Maui.GridBrowser
    {
        id: _gridView
        anchors.fill: parent
        enableLassoSelection: true
        holder.visible: _gridView.count === 0

        itemSize : control.itemSize
        itemHeight: browserSettings.showLabels ? _gridView.itemSize * 1.5 : _gridView.itemSize
        cacheBuffer: control.height * 5

        Loader
        {
            width: parent.width
            anchors.bottom: parent.bottom
            active: control.list.status === GalleryList.Loading
            visible: active
            sourceComponent: Maui.ProgressIndicator {}
        }

        model: Maui.BaseModel
        {
            id: pixModel
            list: control.list

            sort: browserSettings.sortBy
            sortOrder: browserSettings.sortOrder
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        Maui.Chip
        {
            z: parent.z + 99999
            Maui.Theme.colorSet:Maui.Theme.Complementary
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
                const index = control.list.indexOfName(typingQuery)
                if(index > -1)
                {
                    control.currentIndex = pixModel.mappedFromSource(index)
                }

                typingQuery = ""
            }
        }

        PixMenu
        {
            id: _picMenu
            index: control.currentIndex
            model: pixModel
        }

        onItemsSelected: (indexes) =>
        {
            for(var i in indexes)
                selectItem(pixModel.get(indexes[i]))
        }

        onKeyPress: (event) =>
        {
            const index = control.currentIndex
            const item = control.model.get(index)

            var pat = /^([a-zA-Z0-9 _-]+)$/
            if(event.count === 1 && pat.test(event.text))
            {
                typingQuery += event.text
                _typingTimer.restart()
                event.accepted = true
            }

            if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                _gridView.itemsSelected([index])
            }

            if(event.key === Qt.Key_Space)
            {
                getFileInfo(item.url)
                event.accepted = true
            }

            if(event.key === Qt.Key_Return)
            {
                openPic(index)
                event.accepted = true
            }

            if(event.key === Qt.Key_A && (event.modifiers & Qt.ControlModifier))
            {
                selectAll()
                event.accepted = true
            }
        }

        delegate: Item
        {
            height: GridView.view.cellHeight
            width: GridView.view.cellWidth

            PixPic
            {
                id: _gridDelegate

                template.imageWidth: _gridView.itemSize
                template.imageHeight: _gridView.itemSize
                anchors.fill: parent
                anchors.margins: Maui.Handy.isMobile ? 0 : Maui.Style.space.medium

                fit: browserSettings.fitPreviews
                labelsVisible: browserSettings.showLabels
                checkable: root.selectionMode
                radius: Maui.Handy.isMobile ? 0 : Maui.Style.radiusV

                isCurrentItem: parent.GridView.isCurrentItem || checked
                checked: selectionBox.contains(model.url)

                Drag.keys: ["text/uri-list"]
                Drag.mimeData: Drag.active ? { "text/uri-list": control.filterSelectedItems(model.url) } : {}

            onClicked:
            {
                control.currentIndex = index
                if(root.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
                {
                    _gridView.itemsSelected([index])
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
                _picMenu.show()
            }

            onRightClicked:
            {
                control.currentIndex = index
                _picMenu.show()
            }

            onToggled:
            {
                control.currentIndex = index
                selectItem(pixModel.get(index))
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

function selectAll()
{
    for(var item of pixModel.getAll())
    {
        selectionBox.append(item.url, item)
    }
}

function openPic(index)
{
    VIEWER.open(pixModel, index)
}
}
