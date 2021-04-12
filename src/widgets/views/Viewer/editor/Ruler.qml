import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

import org.mauikit.controls 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

Slider
{
    id: control

    live: true

    leftPadding: 0
    rightPadding:  0

    implicitHeight: Maui.Style.toolBarHeight
    implicitWidth: width

    background: Gauge
    {
        x: control.leftPadding
        y: control.topPadding
        implicitWidth: control.horizontal ? 500 : control.width
        implicitHeight: control.horizontal ? control.height : 500
        width: control.horizontal ? control.availableWidth  : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight

        minimumValue: control.from
        value: control.value
        maximumValue: control.to
        orientation: control.orientation
        tickmarkAlignment: Qt.AlignTop
        tickmarkStepSize: isWide ?  45 : 90
        minorTickmarkCount: isWide ? 6 : 4

        Behavior on value {
            NumberAnimation {
                duration: 1000
            }
        }

        style: GaugeStyle {
            valueBar: Item{}

            minorTickmark: Item {
                implicitWidth: 5
                implicitHeight: 2

                Rectangle {
                    color: Kirigami.Theme.textColor
                    anchors.fill: parent
                }
            }

            tickmark: Item {
                implicitWidth: 10
                implicitHeight: 2

                Rectangle {
                    color: Kirigami.Theme.textColor
                    anchors.fill: parent
                }
            }

            tickmarkLabel: Item {
                implicitWidth: 16
                implicitHeight: 16

                Label {
                    visible: control.value !== styleData.value
                    color: Kirigami.Theme.textColor
                    text: styleData.value + "°"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    font.pointSize: Maui.Style.fontSizes.tiny
                }
            }
        }
    }

    handle: Column
    {
        id: handle
        x: (control.horizontal ? control.visualPosition * (control.availableWidth - width) : 0)
        y:  0
        spacing: 0
        width: 32
        //        implicitHeight: Maui.Style.iconSizes.medium

        Rectangle
        {
             width: parent.width
             height: 16
             color: Kirigami.Theme.backgroundColor
             radius: Maui.Style.radiusV
                Label
                {
                   anchors.fill: parent
                    font.bold: true
                    font.weight: Font.Bold
                    font.pointSize: Maui.Style.fontSizes.small
text: control.value + "°"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
        }

        Kirigami.Icon
        {
            anchors.horizontalCenter: parent.horizontalCenter
            height: 32
            width: height
            color: Kirigami.Theme.textColor
            isMask: true
            source: "qrc:/assets/arrow-up.svg"
        }

    }
}
