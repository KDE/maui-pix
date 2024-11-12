
import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.imagetools as IT

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
