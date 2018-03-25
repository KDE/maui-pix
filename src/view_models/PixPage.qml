import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

Page
{

    property int toolbarHeight: 48

    property bool headerbarVisible : true
    property bool headerbarExit : true
    property string headerbarExitIcon : "dialog-close"
    property string headerbarTitle: ""

    property alias headerBarRight : headerbarActionsRight.children
    property alias headerBarLeft : headerbarActionsLeft.children

    property alias content : pageContent.children


    signal exit();

    clip: true


    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        Rectangle
        {
            id: header
            height: toolbarHeight
            Layout.fillWidth: true
            visible: headerbarVisible
            focus: true
            color: backgroundColor

            Kirigami.Separator
            {
                visible: !isMobile
                width: parent.width
                height: 1

                anchors
                {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }

            RowLayout
            {
                id: headerbarLayout
                anchors.fill: parent

                PixButton
                {
                    id: exitBtn
                    Layout.alignment : Qt.AlignLeft
                    Layout.leftMargin: contentMargins
                    visible: headerbarExit
                    anim : true
                    iconName : headerbarExitIcon
                    onClicked : exit()
                }

                Row
                {
                    id: headerbarActionsLeft
                    Layout.alignment : Qt.AlignLeft
                    Layout.leftMargin: headerbarExit ? 0 : contentMargins
                }

                Label
                {
                    text : headerbarTitle || ""
                    Layout.fillHeight : true
                    Layout.fillWidth : true
                    Layout.alignment : Qt.AlignCenter

                    elide : Text.ElideRight
                    font.bold : false
                    color : textColor
                    font.pointSize: fontSizes.big
                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment :  Text.AlignVCenter
                }

                Row
                {
                    id: headerbarActionsRight
                    Layout.alignment : Qt.AlignRight
                    Layout.rightMargin: contentMargins
                }
            }

        }



            Column
            {
                id: pageContent
                Layout.margins: contentMargins
                Layout.fillHeight: true
                Layout.fillWidth: true
            }




    }

}
