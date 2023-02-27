
import QtQuick 2.13

import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import org.mauikit.imagetools 1.3 as IT

IT.OCRPage
{
    id: control
    url: currentPic.url
    headBar.farLeftContent:  ToolButton
    {
        icon.name: "go-previous"
        onClicked:
        {
            control.StackView.view.pop()
        }
    }
}
