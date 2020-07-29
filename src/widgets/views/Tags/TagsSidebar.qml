import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.maui.pix 1.0 as Pix

import GalleryList 1.0

import "../../../view_models"

Maui.Page
{
    id: control
    padding:0
    title: i18n("Tags")
    flickable: _tagsList.flickable

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
        visible: _tagsList.count === 0
        emoji: i18n("qrc:/assets/add-image.svg")
        isMask: false
        title :i18n("No Tags!")
        body: i18n("You can create new tags to organize your gallery")
        emojiSize: Maui.Style.iconSizes.huge
        z: 999
        onActionTriggered: newTagDialog.open()
    }

    Maui.GridView
    {
        id: _tagsList
        anchors.fill: parent
        model: tagsModel
        itemSize: Math.min(200, control.width/3)
        adaptContent: true
        margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.big

        delegate: Maui.ItemDelegate
        {
            id: _delegate
            property string tag : model.tag
            property url tagUrl : "tags:///"+model.tag
            height: _tagsList.cellHeight - Maui.Style.space.medium
            width: _tagsList.cellWidth- Maui.Style.space.medium
            isCurrentItem: GridView.isCurrentItem

            ColumnLayout
            {
                width: _tagsList.itemSize - 10
                height: _tagsList.cellHeight - 20
                anchors.centerIn: parent
                spacing: Maui.Style.space.small

                Item
                {
                    id: _collageLayout
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item
                    {
                        anchors.fill: parent

                        GridLayout
                        {
                            anchors.fill: parent
                            columns: 2
                            rows: 2
                            columnSpacing: 2
                            rowSpacing: 2

                            Repeater
                            {
                                model: Maui.BaseModel
                                {
                                    list: GalleryList
                                    {
                                        urls: tagUrl
                                        autoReload: false
                                        recursive: false
                                        limit: 4
                                    }
                                }

                                delegate: Rectangle
                                {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: Qt.rgba(0,0,0,0.3)
                                    Image
                                    {
                                        anchors.fill: parent
                                        sourceSize.width: 80
                                        sourceSize.height: 80
                                        asynchronous: true
                                        smooth: false
                                        source: model.url
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }
                            }
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask
                        {
                            cached: true
                            maskSource: Item
                            {
                                width: _collageLayout.width
                                height: _collageLayout.height

                                Rectangle
                                {
                                    anchors.fill: parent
                                    radius: 8
                                }
                            }
                        }
                    }
                }

                Maui.ListItemTemplate
                {
                    Layout.fillWidth: true
                    label1.text: model.tag
                    rightLabels.visible: true
                    //                    label2.text: model.count
                    iconSource: model.icon
                    iconSizeHint: Maui.Style.iconSizes.small
                }
            }

            Connections
            {
                target: _delegate
                onClicked:
                {
                    _tagsList.currentIndex = index
                    if(Maui.Handy.singleClick)
                    {
                        currentTag = tagsList.get(index).tag
                        populateGrid(currentTag)
                    }
                }

                onDoubleClicked:
                {
                    _tagsList.currentIndex = index
                    if(!Maui.Handy.singleClick)
                    {
                        currentTag = tagsList.get(index).tag
                        populateGrid(currentTag)
                    }
                }
            }
        }
    }
}


