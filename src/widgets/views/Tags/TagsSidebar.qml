import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.maui.pix 1.0 as Pix

import "../../../view_models"

Maui.Page
{
    id: control

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorGroup: Kirigami.Theme.View

    flickable: _gridView.flickable
    headBar.visible: true
    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Filter")
        onAccepted: _tagsModel.filter = text
        onCleared: _tagsModel.filter = ""
    }

    headBar.rightContent: ToolButton
    {
        icon.name : "list-add"
        onClicked: newTagDialog.open()
    }

    Maui.GridView
    {
        id: _gridView
        anchors.fill: parent

        model: Maui.BaseModel
        {
            id: _tagsModel
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive

            list: Pix.TagsList
            {
                id: _tagsList
            }
        }

        itemSize: Math.min(260, Math.max(140, Math.floor(width* 0.3)))
        itemHeight: itemSize* 1.5

        holder.visible: _gridView.count === 0
        holder.emoji: i18n("qrc:/assets/add-image.svg")
        holder.title :i18n("No Tags!")
        holder.body: i18n("You can create new tags to organize your gallery")
        holder.emojiSize: Maui.Style.iconSizes.huge

        delegate: Item
        {
            height: GridView.view.cellHeight
            width: GridView.view.cellWidth

            Maui.GalleryRollItem
            {
                id: _delegate
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                isCurrentItem: parent.GridView.isCurrentItem

                images: model.preview.split(",")

                label1.text: model.tag
                label1.font.bold: true
                label1.font.weight: Font.Bold
                iconSource: model.icon
                template.iconVisible: width > 150
                template.iconSizeHint: Maui.Style.iconSizes.medium

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
}


