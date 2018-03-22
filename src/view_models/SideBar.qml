import QtQuick 2.0
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

import "../utils/Icons.js" as MdiFont
import "../utils"


Item
{
    id: sidebarRoot

    readonly property int minWidth : 32
    readonly property int maxWidth : 120

    property bool isExanped : false

    width: isExanped ? maxWidth : minWidth
    height: parent.height

    parent: ApplicationWindow.overlay

    //    Rectangle
    //    {
    //        id: sidebarBg
    //        anchors.fill: parent
    //        color : "pink"
    //        Kirigami.Separator
    //        {
    //            anchors.right: parent.right
    //        }

    //    }

    Column
    {
        anchors.fill: parent
        anchors.top: parent.top

        PixButton
        {
            anchors.horizontalCenter: parent.horizontalCenter
            id: menu
            iconName: "application-menu"
            onClicked:
            {
                if(isExanped)
                {
                    columnWidth = minWidth
                    isExanped = false
                }else
                {
                    columnWidth = maxWidth
                    isExanped = true
                }

            }
        }

        PixButton
        {
            anchors.horizontalCenter: parent.horizontalCenter
            id: viewer
            iconName: "fileview-preview"
            text: "Viewer"
            display: isExanped ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
        }

        PixButton
        {
            anchors.horizontalCenter: parent.horizontalCenter
            iconName: "folder-pictures"
            text: "Gallery"
            display: isExanped ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
        }

        PixButton
        {
            anchors.horizontalCenter: parent.horizontalCenter
            iconName: "folder"
            text: "Folders"
            display: isExanped ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
        }

        PixButton
        {
            anchors.horizontalCenter: parent.horizontalCenter
            iconName: "view-group"
            text: "Albums"
            display: isExanped ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
        }

        PixButton
        {
            anchors.horizontalCenter: parent.horizontalCenter
            iconName: "tag"
            text: "Tags"
            display: isExanped ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
        }



    }

}
