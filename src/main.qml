import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami

Kirigami.ApplicationWindow
{
    id: root

    property int defaultColumnWidth: Kirigami.Units.gridUnit * 13
    property int columnWidth: defaultColumnWidth

    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [firstPageComponent, secondPageComponent]

    MouseArea
    {
        id: dragHandle

        visible: pageStack.wideMode

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        x: columnWidth - (width / 2)
        width: Kirigami.Units.devicePixelRatio * 2

        property int dragRange: (Kirigami.Units.gridUnit * 5)
        property int _lastX: -1

        cursorShape: Qt.SplitHCursor

        onPressed: _lastX = mouseX

        onPositionChanged:
        {
            if (mouse.x > _lastX)
            {
                columnWidth = Math.min((defaultColumnWidth + dragRange),
                    columnWidth + (mouse.x - _lastX));
            } else if (mouse.x < _lastX)
            {
                columnWidth = Math.max((defaultColumnWidth - dragRange),
                    columnWidth - (_lastX - mouse.x));
            }
        }

        Rectangle
        {
            anchors.fill: parent

            color: "blue"
        }
    }

    Component
    {
        id: firstPageComponent

        Kirigami.Page
        {
            id: firstPage

            background: Rectangle { color: "red" }
        }
    }

    Component
    {
        id: secondPageComponent

        SwipeView
        {
            id: secondPage
clip: true
            background: Rectangle { color: "green" }

            currentIndex: 1
                anchors.fill: parent

                Item {
                    id: firstPage
                    Label
                    {
                        text: "hahaha"
                    }
                }
                Item {
                    id: thirdPage
                    Label
                    {
                        text: "jajaja"
                    }
                }
        }


    }
}
