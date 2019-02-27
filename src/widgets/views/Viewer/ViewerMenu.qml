import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

Maui.Menu
{


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

    MenuSeparator{}


    Maui.MenuItem
    {
        checkable: true
        checked: tagBarVisible
        text: qsTr("Tag bar")
        onTriggered: toogleTagbar()
    }

    Maui.MenuItem
    {
        checkable: true
        checked: contentIsRised
        text: qsTr("Preview bar")
        onTriggered: contentIsRised ? dropContent() : riseContent()
    }

}
