import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

Menu
{
    MenuItem
    {
        checkable: true
        checked: tagBarVisible
        text: qsTr("Tag bar")
        onTriggered: toogleTagbar()
    }

    MenuItem
    {
        checkable: true
        checked: galleryRoll.visible
        text: qsTr("Preview bar")
        onTriggered: galleryRoll.visible = !galleryRoll.visible
    }

}
