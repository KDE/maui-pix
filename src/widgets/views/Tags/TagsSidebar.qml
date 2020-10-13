import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.maui.pix 1.0 as Pix

import "../../../view_models"

Maui.Page
{
    id: control

    flickable: _gridView.flickable

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Filter")
        onAccepted: tagsModel.filter = text
        onCleared: tagsModel.filter = ""
    }

    Maui.FloatingButton
    {
        id: _overlayButton
        z: 999
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Maui.Style.toolBarHeight
        anchors.bottomMargin: Maui.Style.toolBarHeight + _gridView.flickable.bottomMargin
        icon.name : "list-add"
        onClicked: newTagDialog.open()
    }

    Maui.GridView
    {
        id: _gridView
        anchors.fill: parent

        model: tagsModel
        itemSize: Math.min(200, Math.max(100, Math.floor(width* 0.3)))
        itemHeight: itemSize + Maui.Style.rowHeight

        holder.visible: _gridView.count === 0
        holder.emoji: i18n("qrc:/assets/add-image.svg")
        holder.title :i18n("No Tags!")
        holder.body: i18n("You can create new tags to organize your gallery")
        holder.emojiSize: Maui.Style.iconSizes.huge

        delegate: CollageDelegate
        {
            id: _delegate
            property string tag : model.tag
            property url tagUrl : "tags:///"+model.tag
            height: _gridView.cellHeight
            width: _gridView.cellWidth
            isCurrentItem: GridView.isCurrentItem

            contentWidth: _gridView.itemSize - 10
            contentHeight: _gridView.cellHeight - 20

            list.urls: tagUrl

            template.label1.text: model.tag
            template.iconSource: model.icon
            template.iconVisible: true

            onClicked:
            {
                _gridView.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    populateGrid(model.tag)
                }
            }

            onDoubleClicked:
            {
                _gridView.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    populateGrid(model.tag)
                }
            }
        }
    }
}


