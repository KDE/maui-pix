import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "../../../view_models"
import GalleryList 1.0

ScrollView
{
    id: control
    property alias rollList : rollList
    property alias model: rollList.model

    signal picClicked(int index)
    contentHeight: height
    contentWidth: rollList.contentWidth

    ScrollBar.horizontal: ScrollBar {parent: control; visible: false}
    ScrollBar.vertical: ScrollBar {parent: control; visible: false}

    ListView
    {
        id: rollList
        anchors.fill: parent
        currentIndex: currentPicIndex
        orientation: ListView.Horizontal
        clip: true
        spacing: Maui.Style.space.medium

        focus: true
        interactive: true

        model: pixViewer.model

        delegate: PixPic
        {
            id: delegate
            height: parent.height
            width: height

            labelsVisible: false
            fit: false
            checkable: false
            dropShadow: true
            isCurrentItem: ListView.isCurrentItem
            radius:  Maui.Style.radiusV
            Connections
            {
                target: delegate
                onClicked:
                {
                    rollList.currentIndex = index
                    picClicked(index)
                }

                onPressAndHold: _picMenu.popup()
                onRightClicked: _picMenu.popup()
            }
        }
    }

    function position(index)
    {
        rollList.currentIndex = index
        rollList.positionViewAtIndex(index, ListView.Center)
    }
}

