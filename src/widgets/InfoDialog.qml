import QtQuick 2.13
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.8 as Kirigami
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Pix 1.0 as Pix

Maui.Dialog
{
    id: control
    property alias url : _infoModel.url
    maxHeight: 800
    maxWidth: 600

    Kirigami.ScrollablePage
    {
        id: _infoContent
        anchors.fill: parent

        Kirigami.Theme.backgroundColor: "transparent"
        padding:  0
        leftPadding: padding
        rightPadding: padding
        topPadding: padding
        bottomPadding: padding

        ColumnLayout
        {
            width: parent.width
            spacing: 0

            Rectangle
            {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                color: Qt.darker(Kirigami.Theme.backgroundColor)

                Image
                {
                    anchors.fill: parent
                    source: control.url
                    fillMode: Image.PreserveAspectFit
                }
            }

            Kirigami.Separator
            {
                Layout.fillWidth: true
            }

            ListView
            {
                Layout.preferredHeight: contentHeight
                Layout.fillWidth: true
                Layout.margins: 0
                spacing: 0
                model: Maui.BaseModel
                {
                    list: Pix.PicInfoModel
                    {
                        id:_infoModel
                    }
                }

                delegate: Rectangle
                {
                    visible: model.value.length
                    width: visible ? parent.width : 0
                    height: visible ? _delegateColumnInfo.implicitHeight + Maui.Style.space.large : 0

                    color: index % 2 === 0 ? Kirigami.Theme.backgroundColor : Qt.darker(Kirigami.Theme.backgroundColor)
                    Kirigami.Separator
                    {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                    }

                    Column
                    {
                        id: _delegateColumnInfo
                        spacing: Maui.Style.space.tiny
                        width: parent.width * 0.9

                        anchors.centerIn: parent
                        anchors.margins: Maui.Style.space.medium

                        Label
                        {
                            width: parent.width
                            text: model.key
                            color: Kirigami.Theme.textColor
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                            horizontalAlignment: Qt.AlignLeft
                            font.weight: Font.Bold
                            font.bold: true
                        }

                        Label
                        {
                            id: _valueLabel
                            width: parent.width
                            visible: text.length
                            text: model.value
                            color: Kirigami.Theme.textColor
                            elide: Qt.ElideMiddle
                            wrapMode: Text.Wrap
                            horizontalAlignment: Qt.AlignLeft
                            font.weight: Font.Light
                        }


                    }
                }
            }
        }
    }
}
