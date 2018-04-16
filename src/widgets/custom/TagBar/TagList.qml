import QtQuick 2.0
import QtQuick.Controls 2.2

import "../../../db/Query.js" as Q

ListView
{
    orientation: ListView.Horizontal
    clip: true
    spacing: contentMargins
    signal tagRemoved(int index)

    Label
    {
        height: parent.height
        width: parent.width
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter
        text: qsTr("Add tags...")
        opacity: 0.7
        visible: count === 0
        font.pointSize: fontSizes.default
    }

    model: ListModel{}

    delegate: TagDelegate
    {
        id: delegate

        Connections
        {
            target: delegate
            onRemoveTag: tagRemoved(index)
        }
    }

    function populate(query)
    {
        model.clear()
        var tags = pix.get(query)

        if(tags.length > 0)
            for(var i in tags)
                model.append(tags[i])
    }
}
