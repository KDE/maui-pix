import QtQuick 2.14

import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.pix 1.0

import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets"

Maui.Page
{
    id: control

    property int itemSize : browserSettings.previewSize

    property alias list : pixList
    property alias listModel : pixModel
    property alias menu : _picMenu
    property alias holder : _holder
    property alias model: _gridView.model

    property alias currentIndex: _gridView.currentIndex
    property string typingQuery

    Maui.Holder
    {
        id: _holder
        anchors.fill: parent
        visible: _gridView.count === 0
        emojiSize: Maui.Style.iconSizes.huge
    }

    showTitle: false
    headBar.forceCenterMiddleContent: false
    headBar.visible: true
    headBar.middleContent: Maui.TextField
    {
        enabled: list.count > 0
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Search") + " " + pixList.count + " images"
        onAccepted: model.filter = text
        onCleared: model.filter = ""
    }

    Maui.GridView
    {
        id: _gridView
        anchors.fill: parent
        enableLassoSelection: true

        itemSize : control.itemSize
        itemHeight: browserSettings.showLabels ? _gridView.itemSize * 1.5 : _gridView.itemSize
        cacheBuffer: control.height * 5

        Maui.ProgressIndicator
        {
            width: parent.width
            anchors.bottom: parent.bottom
            visible: pixList.status === GalleryList.Loading
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


        Maui.Chip
        {
            z: parent.z + 99999
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

        onItemsSelected:
        {
            for(var i in indexes)
                selectItem(pixModel.get(indexes[i]))
        }

        onKeyPress:
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
                anchors.margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.medium

                fit: browserSettings.fitPreviews
                labelsVisible: browserSettings.showLabels
                checkable: root.selectionMode
                maskRadius: Kirigami.Settings.isMobile ? 0 : Maui.Style.radiusV

                isCurrentItem: parent.GridView.isCurrentItem || checked
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

function openPic(index)
{
    VIEWER.open(pixModel, index)
}
}
