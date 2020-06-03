import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

Maui.Page
{
    id: control
    headBar.farLeftContent: ToolButton
    {
        icon.name: "go-previous"
        onClicked: control.parent.pop()
    }

}
