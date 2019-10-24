import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import "../../"
import "Viewer.js" as VIEWER

Maui.Page
{
    property bool autoSaveTransformation : false
    property real picContrast : 0
    property real picBrightness : 0
    property real picSaturation : 0
    property real picHue : 0
    property real picLightness : 0

    property alias count : viewerList.count
    property alias currentIndex : viewerList.currentIndex
    property alias currentItem: viewerList.currentItem
    headBar.visible: false

    clip: true
    focus: true
    Kirigami.Theme.backgroundColor: viewerBackgroundColor

    ListView
    {
        id: viewerList
        height: parent.height
        width: parent.width
        orientation: ListView.Horizontal
        currentIndex: currentPicIndex
        clip: true
        focus: true
        interactive: true
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        snapMode: ListView.SnapOneItem
        model: pixModel
        onMovementEnded:
        {
            var index = indexAt(contentX, contentY)
            if(index !== currentPicIndex)
                VIEWER.view(index)
        }

        delegate: ViewerDelegate
        {
            id: delegate
            itemHeight: viewerList.height
            itemWidth: viewerList.width

            Connections
            {
                target: delegate

                onPressAndHold: _picMenu.popup()
                onRightClicked: _picMenu.popup()
            }
        }
    }


    function appendPics(pics)
    {
        if(pics.length > 0)
            for(var i in pics)
                viewerList.model.list.append(pics[i])

    }

}
