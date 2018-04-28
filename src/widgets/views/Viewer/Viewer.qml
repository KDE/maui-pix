import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../"
import "Viewer.js" as VIEWER

Item
{
    property bool autoSaveTransformation : false
    property real picContrast : 0
    property real picBrightness : 0
    property real picSaturation : 0
    property real picHue : 0
    property real picLightness : 0

    property alias list : viewerList
    clip: true

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

        onMovementEnded:
        {
            var index = indexAt(contentX, contentY)
            if(index !== currentPicIndex)
                VIEWER.view(index)
        }

        model : ListModel{}

        delegate: ViewerDelegate
        {
            id: delegate
            itemHeight: viewerList.height
            itemWidth: viewerList.width

        }
    }


    function populate(pics)
    {
        viewerList.model.clear()
        if(pics.length > 0)
            for(var i in pics)
            {
                console.log("Appending to viewer", pics[i].url)
                viewerList.model.append(pics[i])

            }
    }
}
