import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Menu
{
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    modal: true
    focus: true
    parent: ApplicationWindow.overlay

    margins: 1
    padding: 2
}
