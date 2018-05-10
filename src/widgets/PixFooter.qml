import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.maui 1.0 as Maui

import "../widgets/views/Viewer/Viewer.js" as VIEWER

Row
{
    spacing: space.medium
    id: footerToolbar


    Maui.ToolButton
    {
        iconName: "go-previous"
        onClicked: VIEWER.previous()
    }

    Maui.ToolButton
    {
        id: favIcon
        iconName: "love"
        iconColor: pixViewer.currentPicFav? pix.pixColor() : textColor
        onClicked: pixViewer.currentPicFav = VIEWER.fav(pixViewer.currentPic.url)
    }

    Maui.ToolButton
    {
        iconName: "go-next"
        onClicked: VIEWER.next()
    }
}
