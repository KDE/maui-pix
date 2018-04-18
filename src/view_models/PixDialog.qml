import QtQuick 2.9
import QtQuick.Controls 2.2

Dialog
{
    width: parent.width * (isMobile ? 0.7 : 0.5)
    height: parent.height * (isMobile ? 0.7 : 0.5)

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: ApplicationWindow.overlay

    modal: true

    margins: 1
    padding: space.tiny*0.5
}
