import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

import org.maui.pix

import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets"

Maui.Page
{
    id: control

    Maui.Theme.inherit: false
    Maui.Theme.colorGroup: Maui.Theme.View

    Keys.forwardTo: _gridView
    Keys.enabled: true

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
    padding: 0

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
            _gridView.forceActiveFocus()
        }

        Keys.enabled: true
        Keys.priority: Keys.AfterItem
        Keys.onEscapePressed: _gridView.forceActiveFocus()
        Keys.onPressed: (event)=>
                        {
                            if(event.key === Qt.Key_Return)
                            {
                                // _gridView.forceActiveFocus()
                                event.accepted = true
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

    property Component extraOptions : Maui.ToolButtonMenu
    {
        icon.name: "view-sort"

        Maui.FlexSectionItem
        {
            label1.text: i18n("Preview Size")
            label2.text: i18n("Size of the thumbnails in the collection views.")
            wide: false
            Maui.ToolActions
            {
                id: _gridIconSizesGroup
                expanded: true
                autoExclusive: true
                display: ToolButton.TextOnly

                Action
                {
                    text: i18n("S")
                    onTriggered: setPreviewSize(previewSizes.small)
                    checked: previewSizes.small === browserSettings.previewSize
                }

                Action
                {
                    text: i18n("M")
                    onTriggered: setPreviewSize(previewSizes.medium)
                    checked: previewSizes.medium === browserSettings.previewSize

                }

                Action
                {
                    text: i18n("X")
                    onTriggered: setPreviewSize(previewSizes.large)
                    checked: previewSizes.large === browserSettings.previewSize

                }

                Action
                {
                    text: i18n("XL")
                    onTriggered: setPreviewSize(previewSizes.extralarge)
                    checked: previewSizes.extralarge === browserSettings.previewSize

                }
            }
        }

        MenuSeparator{}

        MenuItem
        {
            text: i18n("Title")
            checkable: true
            autoExclusive: true
            onTriggered: browserSettings.sortBy = "title"
            checked: browserSettings.sortBy === "title"
        }

        MenuItem
        {
            text: i18n("Modified")
            checkable: true
            autoExclusive: true
            onTriggered: browserSettings.sortBy = "modified"
            checked: browserSettings.sortBy === "modified"

        }

        MenuItem
        {
            text: i18n("Size")
            checkable: true
            autoExclusive: true
            onTriggered: browserSettings.sortBy = "size"
            checked: browserSettings.sortBy === "size"

        }

        MenuItem
        {
            text: i18n("Date")
            checkable: true
            autoExclusive: true
            onTriggered: browserSettings.sortBy = "date"
            checked: browserSettings.sortBy === "date"

        }

        MenuSeparator {}

        MenuItem
        {
            text: i18n("Ascending")
            checkable: true
            // autoExclusive: true
            icon.name: "view-sort-ascending"
            onTriggered: browserSettings.sortOrder = Qt.AscendingOrder
            checked: browserSettings.sortOrder === Qt.AscendingOrder
        }

        MenuItem
        {
            text: i18n("Descending")
            checkable: true
            // autoExclusive: true
            icon.name: "view-sort-descending"
            onTriggered: browserSettings.sortOrder = Qt.DescendingOrder
            checked: browserSettings.sortOrder === Qt.DescendingOrder
        }
    }

    Maui.GridBrowser
    {
        id: _gridView
        anchors.fill: parent
        enableLassoSelection: true
        holder.visible: _gridView.count === 0
        // padding: 0

        itemSize : control.itemSize
        itemHeight: browserSettings.showLabels ? _gridView.itemSize * 1.5 : _gridView.itemSize
        cacheBuffer: control.height * 5
        flickable.reuseItems: true

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

            // editMenuItem.action: Action
            // {
            //     shortcut: "Ctrl+E"
            //     onTriggered: openEditor(pixModel.get(currentIndex).url, _stackView)
            // }
        }

        onItemsSelected: (indexes) =>
                         {
                             for(var i in indexes)
                             selectItem(pixModel.get(indexes[i]))
                         }


        Keys.enabled: true
        Keys.onPressed: (event) =>
                        {
                            const index = control.currentIndex
                            const item = control.model.get(index)

                            var pat = /^([a-zA-Z0-9 _-]+)$/
                            if(event.count === 1 && pat.test(event.text))
                            {
                                typingQuery += event.text
                                _typingTimer.restart()
                                event.accepted = true
                                return
                            }

                            if(event.key == Qt.Key_S && (event.modifiers & Qt.ControlModifier))
                            {
                                _gridView.itemsSelected([index])
                                event.accepted = true
                            }

                            if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
                            {
                                _gridView.itemsSelected([index])
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_Space)
                            {
                                getFileInfo(item.url)
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_Return)
                            {
                                openPic(pixModel.mappedToSource(index))
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_A && (event.modifiers & Qt.ControlModifier))
                            {
                                selectAll()
                                event.accepted = true
                                return
                            }

                            if(event.key === Qt.Key_O && (event.modifiers & Qt.ControlModifier))
                            {
                                openFileWith(filterSelection(item.url))
                                event.accepted = true
                                return
                            }

                            event.accepted = false
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
                checkable: root.selectionMode || checked
                radius: Maui.Handy.isMobile ? 0 : Maui.Style.radiusV

                isCurrentItem: parent.GridView.isCurrentItem || checked
                checked: selectionBox.contains(model.url)

                Drag.keys: ["text/uri-list"]
                Drag.mimeData: Drag.active ? { "text/uri-list": filterSelection(model.url) } : {}

            onClicked: (mouse) =>
                       {
                           if(root.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
                           {
                               _gridView.itemsSelected([index])
                           }else if((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ShiftModifier))
                           {
                               _gridView.itemsSelected(control.range(control.currentIndex, index))
                           }else if(Maui.Handy.singleClick)
                           {
                               openPic(pixModel.mappedToSource(index))
                           }
                           control.currentIndex = index
                       }

            onDoubleClicked:
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick && !root.selectionMode)
                {
                    openPic(pixModel.mappedToSource(index))
                }
            }

            onPressAndHold:
            {
                control.currentIndex = index
                if(Maui.Handy.hasTransientTouchInput)
                {
                    _picMenu.show()
                }
            }

            onRightClicked:
            {
                control.currentIndex = index
                _picMenu.show()
            }

            onToggled: (state) =>
                       {
                           console.log("ITEM TOGGLED!!", state)
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

/**
 * @private
 */
function range(start, end)
{
    const isReverse = (start > end);
    const targetLength = isReverse ? (start - end) + 1 : (end - start ) + 1;
    const arr = new Array(targetLength);
    const b = Array.apply(null, arr);
    const result = b.map((discard, n) => {
                             return (isReverse) ? n + end : n + start;
                         });

    return (isReverse) ? result.reverse() : result;
}
}
