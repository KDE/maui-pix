// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import QtQuick.Controls 2.10
import QtQuick 2.10
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import GalleryList 1.0

import "../widgets/views/Viewer/Viewer.js" as VIEWER
import "../widgets/views/Pix.js" as PIX
import "../widgets"

MauiLab.AltBrowser
{
    id: control
    focus: true
    viewType: MauiLab.AltBrowser.ViewType.Grid
    property int itemSize : root.previewSize

    property alias list : pixList
    property alias menu : _picMenu
    property alias count: pixList.count

    /*signals*/
    signal picClicked(int index)
    padding: 0
    showTitle: false

    enableLassoSelection: !Kirigami.Settings.hasTransientTouchInput

    gridView.itemSize : control.itemSize
    gridView.margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.big

    listView.topMargin: Maui.Style.contentMargins
    listView.spacing: Maui.Style.space.medium
    listView.section.criteria: model.sort === "title" ?  ViewSection.FirstCharacter : ViewSection.FullString
    listView.section.property: model.sort
    listView.section.delegate: Maui.LabelDelegate
    {
        id: delegate
        width: parent.width
        height: Maui.Style.toolBarHeightAlt
        label: model.sort === "date" || model.sort === "modified" ? Maui.FM.formatDate(Date(section), "MM/dd/yyyy") : (model.sort === "size" ? Maui.FM.formatSize(section)  : String(section).toUpperCase())
        labelTxt.font.pointSize: Maui.Style.fontSizes.big
        isSection: true
    }

    holder.visible: pixList.count === 0
    holder.isMask: true
    holder.emojiSize: Maui.Style.iconSizes.huge

    headBar.middleContent: Maui.TextField
    {
        enabled: list.count > 0
        Layout.fillWidth: true
        placeholderText: i18n("Search") + " " + count + " images"
        onAccepted: model.filter = text
        onCleared: model.filter = ""
    }

    headBar.leftContent: Maui.ToolActions
    {
        autoExclusive: true
        expanded: isWide
        currentIndex : control.viewType === MauiLab.AltBrowser.ViewType.List ? 0 : 1
        enabled: list.count > 0
        display: ToolButton.TextBesideIcon
        Action
        {
            text: i18n("List")
            icon.name: "view-list-details"
            onTriggered: control.viewType = MauiLab.AltBrowser.ViewType.List
        }

        Action
        {
            text: i18n("Grid")
            icon.name: "view-list-icons"
            onTriggered: control.viewType= MauiLab.AltBrowser.ViewType.Grid
        }
    }

    headBar.rightContent: [

        Maui.ToolButtonMenu
        {
            enabled: list.count > 0
            icon.name: "view-sort"
            MenuItem
            {
                text: i18n("Title")
                checkable: true
                checked: pixModel.sort === "title"
                onTriggered: pixModel.sort = "title"
            }

            MenuItem
            {
                text: i18n("Modified")
                checkable: true
                checked: pixModel.sort === "modified"
                onTriggered: pixModel.sort = "modified"
            }

            MenuItem
            {
                text: i18n("Creation date")
                checkable: true
                checked: pixModel.sort === "date"
                onTriggered: pixModel.sort = "date"
            }

            MenuItem
            {
                text: i18n("Format")
                checkable: true
                checked: pixModel.sort === "format"
                onTriggered: pixModel.sort = "format"
            }

            MenuItem
            {
                text: i18n("Size")
                checkable: true
                checked: pixModel.sort === "size"
                onTriggered: pixModel.sort = "size"
            }

            MenuSeparator {}

            MenuItem
            {
                text: i18n("Ascending")
                onTriggered: pixModel.sortOrder = Qt.AscendingOrder
                checked: pixModel.sortOrder === Qt.AscendingOrder
                checkable: true
            }

            MenuItem
            {
                text: i18n("Descending")
                onTriggered: pixModel.sortOrder = Qt.DescendingOrder
                checked: pixModel.sortOrder === Qt.DescendingOrder
                checkable: true
            }
        }
    ]

    GalleryList
    {
        id: pixList
        autoReload: root.autoReload
        autoScan: root.autoScan
    }

    model: Maui.BaseModel
    {
        id: pixModel
        list: pixList
        sort: "date"
        sortOrder: Qt.DescendingOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    Connections
    {
        target: control.currentView

        onItemsSelected:
        {
            for(var i in indexes)
                PIX.selectItem(pixModel.get(indexes[i]))
        }

        onKeyPress:
        {
            const index = control.currentIndex
            const item = control.model.get(index)

            if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                control.currentView.itemsSelected([index])
            }

            if(event.key === Qt.Key_Space)
            {
                getFileInfo(item.url)
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
        height: Maui.Style.rowHeight *1.5
        width: parent.width
        leftPadding: Maui.Style.space.small
        rightPadding: Maui.Style.space.small

        isCurrentItem: (ListView.isCurrentItem || checked)
        checked: selectionBox.contains(model.url)
        checkable: selectionMode
        Drag.keys: ["text/uri-list"]
        Drag.mimeData: Drag.active ? {"text/uri-list": control.filterSelectedItems(model.url)} : {}

    onClicked:
    {
        control.currentIndex = index
        if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
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
        if(!Maui.Handy.singleClick && !selectionMode)
        {
            openPic(index)
        }
    }

    onPressAndHold:
    {
        control.currentIndex = index
        _picMenu.popup()
    }

    onRightClicked:
    {
        control.currentIndex = index
        _picMenu.popup()
    }
    onToggled:
    {
        control.currentIndex = index
        PIX.selectItem(pixModel.get(index))
    }

    Connections
    {
        target: selectionBox
        onUriRemoved:
        {
            if(uri === model.url)
            {
                _listDelegate.checked = false
            }
        }

        onUriAdded:
        {
            if(uri === model.url)
            {
                _listDelegate.checked = true
            }
        }

        onCleared: _listDelegate.checked = false
    }
}

gridDelegate: PixPic
{
    id: _gridDelegate
    property int spacing : Kirigami.Settings.isMobile ? 2 : Maui.Style.space.big*1.2
    fit: fitPreviews
    labelsVisible: showLabels
    height: control.gridView.cellHeight - spacing
    width: control.gridView.cellWidth - spacing
    checkable: selectionMode

    isCurrentItem: (GridView.isCurrentItem || checked)
    checked: selectionBox.contains(model.url)

    Drag.keys: ["text/uri-list"]
    Drag.mimeData: Drag.active ? { "text/uri-list": control.filterSelectedItems(model.url) } : {}

    onClicked:
    {
        control.currentIndex = index
        if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
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
        if(!Maui.Handy.singleClick && !selectionMode)
        {
            openPic(index)
        }
    }

    onPressAndHold:
    {
        control.currentIndex = index
        _picMenu.popup()
    }

    onRightClicked:
    {
        control.currentIndex = index
        _picMenu.popup()
    }
    onToggled:
    {
        control.currentIndex = index
        PIX.selectItem(pixModel.get(index))
    }

    Connections
    {
        target: selectionBox
        onUriRemoved:
        {
            if(uri === model.url)
            {
                _gridDelegate.checked = false
            }
        }

        onUriAdded:
        {
            if(uri === model.url)
            {
                _gridDelegate.checked = true
            }
        }

        onCleared: _gridDelegate.checked = false
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
