import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

Page
{

    property int toolbarHeight: 48
    property int pageMargins : contentMargins
    property bool headerbarVisible : true
    property bool headerbarExit : true
    property string headerbarExitIcon : "dialog-close"
    property string headerbarTitle: ""

    property alias headerBarRight : headerbarActionsRight.children
    property alias headerBarLeft : headerbarActionsLeft.children
    property alias headerBar : header
    property alias content : pageContent.children


    signal exit();

    clip: true
    padding: 0

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        ToolBar
        {
            id: header
            Layout.fillWidth: true
            visible: headerbarVisible

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
                    spacing: contentMargins

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
                    spacing: contentMargins
                    Layout.alignment : Qt.AlignRight
                    Layout.rightMargin: contentMargins
                }
            }

        }

        Column
        {
            id: pageContent
            Layout.margins: pageMargins
            Layout.fillHeight: true
            Layout.fillWidth: true
        }




    }

}
