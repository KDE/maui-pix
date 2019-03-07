import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import FMList 1.0

import "../../../view_models"

Maui.Menu
{
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
        checked: galleryRoll.visible
        text: qsTr("Preview bar")
        onTriggered: galleryRoll.visible = !galleryRoll.visible
    }

}
