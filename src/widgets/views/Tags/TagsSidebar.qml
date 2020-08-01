import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.maui.pix 1.0 as Pix

import GalleryList 1.0

import "../../../view_models"

Maui.GridView
{
    id: control
    model: tagsModel
    itemSize: Math.min(200, control.width/3)
    itemHeight: 200
    margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.big

    Maui.FloatingButton
    {
        id: _overlayButton
        z: 999
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Maui.Style.toolBarHeight
        anchors.bottomMargin: Maui.Style.toolBarHeight
        icon.name : "list-add"
        onClicked: newTagDialog.open()
    }

    Maui.Holder
    {
        visible: control.count === 0
        emoji: i18n("qrc:/assets/add-image.svg")
        isMask: false
        title :i18n("No Tags!")
        body: i18n("You can create new tags to organize your gallery")
        emojiSize: Maui.Style.iconSizes.huge
        z: 999
        onActionTriggered: newTagDialog.open()
    }


    delegate: CollageDelegate
    {
        id: _delegate
        property string tag : model.tag
        property url tagUrl : "tags:///"+model.tag
        height: control.cellHeight - Maui.Style.space.medium
        width: control.cellWidth- Maui.Style.space.medium
        isCurrentItem: GridView.isCurrentItem

        contentWidth: control.itemSize - 10
        contentHeight: control.cellHeight - 20

        list.urls: tagUrl

        template.label1.text: model.tag
        template.iconSource: model.icon

        onClicked:
        {
            control.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                currentTag = tagsList.get(index).tag
                populateGrid(currentTag)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                currentTag = tagsList.get(index).tag
                populateGrid(currentTag)
            }
        }

    }
}


