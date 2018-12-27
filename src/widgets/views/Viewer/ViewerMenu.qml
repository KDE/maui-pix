import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

Maui.Menu
{
    property alias menuItems: viewerMenuLayout.children

    Maui.MenuItem
    {
        text: qsTr(tagBarVisible ? "Hide Tag bar" :
                                   "Show Tag bar")
        onTriggered: toogleTagbar()

    }

    Maui.MenuItem
    {
        text: "Configurations..."
        onTriggered:
        {
            viewerConf.open()
            close()
        }
    }

    Maui.MenuItem
    {
        text: "Open..."
        onTriggered:
        {
            dialogLoader.sourceComponent= fmDialogComponent
            dialog.mode = dialog.modes.OPEN
            dialog.show(function(paths)
            {

                    console.log("OPEN IMAGE", paths)

            });
            close()
        }
    }

    Column
    {
        id: viewerMenuLayout
    }
}
