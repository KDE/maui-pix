import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

import "../../../view_models"

PixMenu
{
    property alias menuItems: viewerMenuLayout.children

    MenuItem
    {
        text: qsTr(tagBarVisible ? "Hide Tag bar" :
                                   "Show Tag bar")
        onTriggered: toogleTagbar()

    }

    MenuItem
    {
        text: "Configurations..."
        onTriggered:
        {
            viewerConf.open()
            close()
        }
    }

    MenuItem
    {
        text: "Sort..."
        onTriggered: {close()}
    }

    Column
    {
        id: viewerMenuLayout
    }
}
