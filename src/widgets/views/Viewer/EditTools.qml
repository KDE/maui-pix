import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

Drawer
{
    modal: false
    edge: Qt.RightEdge
    spacing: 0
    ScrollView
    {
        anchors.fill: parent
        clip: true
        contentWidth: parent.width
        contentHeight: parent.height

        Column
        {
            anchors.fill: parent

spacing: contentMargins
            ToolBar
            {
                width: parent.width
                position: ToolBar.Header
                RowLayout
                {
                    anchors.fill: parent
                    anchors.centerIn: parent

                    Item
                    {
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        PixButton
                        {
                            anchors.centerIn: parent
                            iconName: "object-rotate-left"
                            onClicked: viewer.rotateLeft()
                        }
                    }

                    Item
                    {
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        PixButton
                        {
                            anchors.centerIn: parent
                            iconName: "object-rotate-right"
                            onClicked: viewer.rotateRight()
                        }
                    }
                }
            }

            GridLayout
            {
                width: parent.width* 0.9
                anchors.horizontalCenter: parent.horizontalCenter
                rows:3
                columns: 2
                columnSpacing: contentMargins

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 1
                    Layout.column: 1
                    Layout.columnSpan: 2
                    width: parent.width
                    text: qsTr("Color")
                    font.pointSize: fontSizes.big
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 2
                    Layout.column: 1

                    text: qsTr("Contrast")
                }
                Slider
                {
                    id: contrastSlider
                    Layout.fillWidth: true
                    width: 60
                    Layout.row: 2
                    Layout.column: 2
                    value: 50
                    from: 0
                    to: 100
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 3
                    Layout.column: 1

                    text: qsTr("Brightness")
                }

                Slider
                {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    width: 60
                    Layout.row: 3
                    Layout.column: 2
                    value: 50
                    from: 0
                    to: 100
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 4
                    Layout.column: 1

                    text: qsTr("Saturation")
                }

                Slider
                {
                    id: saturationSlider
                    Layout.fillWidth: true
                    width: 60
                    Layout.row: 4
                    Layout.column: 2
                    value: 50
                    from: 0
                    to: 100
                }

            }
        }
    }
}
