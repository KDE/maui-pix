import QtQuick 2.13
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.8 as Kirigami
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import org.maui.pix 1.0 as Pix
import QtQuick.Shapes 1.12

Maui.Dialog
{
    id: control
    property alias url : _infoModel.url
    maxHeight: 800
    maxWidth: 500
    defaultButtons: false
    page.title: _infoModel.fileName
    headBar.visible: true
    page.flickable: _infoContent.flickable

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
                Layout.preferredHeight: 200
                color: Qt.darker(Kirigami.Theme.backgroundColor, 1.1)

                Image
                {
                    id: _img
                    anchors.fill: parent
                    source: control.url
                    fillMode: Image.PreserveAspectCrop

                    Rectangle
                    {
                        color: "#333"
                        opacity: 0.5
                        anchors.fill: parent
                    }

                    Rectangle
                    {
                        anchors.centerIn: parent
                        color: "#333"
                        radius: Maui.Style.radiusV
                        width: 100
                        height: 32
                        Label
                        {
                            anchors.centerIn: parent
                            text: _img.sourceSize.height + " x " + _img.sourceSize.width
                            color: "white"
                        }
                    }
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

                    color: index % 2 === 0 ? Kirigami.Theme.backgroundColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.1)
                    Kirigami.Separator
                    {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                    }

                    Maui.ListItemTemplate
                    {
                        id: _delegateColumnInfo
                        width: parent.width

                        iconSource: "documentinfo"
                        iconSizeHint: Maui.Style.iconSizes.medium

                        anchors.centerIn: parent
                        anchors.margins: Maui.Style.space.medium

                        label1.text: model.key
                        label1.font.weight: Font.Bold
                        label1.font.bold: true
                        label2.text: model.value
                        label2.elide: Qt.ElideMiddle
                        label2.wrapMode: Text.Wrap
                        label2.font.weight: Font.Light
                    }
                }
            }
        }
    }
}
