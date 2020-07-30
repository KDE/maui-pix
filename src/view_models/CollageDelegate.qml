import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.12 as Kirigami
import org.kde.mauikit 1.2 as Maui

import FoldersList 1.0
import GalleryList 1.0

Maui.ItemDelegate
{
    id: control
    property var folderPath : [model.path]
    property alias list : _galleryList
    property alias template : _template
    property int contentWidth: Maui.Style.iconSizes.huge
    property int contentHeight: Maui.Style.iconSizes.huge

    function randomHexColor()
    {
        var color = '#', i = 5;
        do{ color += "0123456789abcdef".substr(Math.random() * 16,1); }while(i--);
        return color;
    }

    ColumnLayout
    {
        width: control.contentWidth
        height: control.contentHeight
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

                Rectangle
                {
                    anchors.fill: parent
                    radius: 8
                    color: randomHexColor()
                    visible: _repeater.count === 0
                }

                GridLayout
                {
                    anchors.fill: parent
                    columns: 2
                    rows: 2
                    columnSpacing: 2
                    rowSpacing: 2

                    Repeater
                    {
                        id: _repeater
                        model: Maui.BaseModel
                        {
                            list: GalleryList
                            {
                                id: _galleryList
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
            id: _template
            Layout.fillWidth: true
            rightLabels.visible: true
            iconSizeHint: Maui.Style.iconSizes.small
        }
    }
}
