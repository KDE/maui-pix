import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

import "../../../view_models"

PixMenu
{
    property alias menuItems: viewerMenuLayout.children

    Column
    {
        id: viewerMenuLayout
        MenuItem
        {
            text: qsTr(tagBarVisible ? "Hide Tag bar" :
                                       "Show Tag bar")
            onTriggered:
            {
                tagBarVisible = !tagBarVisible
                pix.saveSettings("TAGBAR", tagBarVisible, "PIX")
            }
        }

        Kirigami.Separator{ width: parent.width; height: 1}

        MenuItem
        {
            text: "Configurations..."
            onTriggered:
            {
                viewerConf.open()
                close()
            }
        }

        Kirigami.Separator{ width: parent.width; height: 1}

        MenuItem
        {
            text: "Sort..."
            onTriggered: {close()}
        }
    }
}
