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
                rows: 11
                columns: 1
                columnSpacing: contentMargins

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 1
                    Layout.column: 1
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
                    width: parent.width
                    Layout.fillWidth: true
                    Layout.row: 3
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picContrast = value
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 4
                    Layout.column: 1
                    width: parent.width

                    text: qsTr("Brightness")
                }

                Slider
                {
                    id: brightnessSlider
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.row: 5
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picBrightness = position
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 6
                    Layout.column: 1
                    width: parent.width

                    text: qsTr("Saturation")
                }

                Slider
                {
                    id: saturationSlider
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.row: 7
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picSaturation = value
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 8
                    Layout.column: 1
                    width: parent.width

                    text: qsTr("Hue")
                }

                Slider
                {
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.row: 9
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picHue = value
                }

                Label
                {
                    Layout.fillWidth: true
                    Layout.row: 10
                    Layout.column: 1
                    width: parent.width

                    text: qsTr("Lightness")
                }

                Slider
                {
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.row: 11
                    Layout.column: 1
                    value: 0
                    from: -1
                    to: 1
                    onMoved: viewer.picLightness = value
                }

            }
        }
    }
}
