import QtQuick 2.0
import "../../../db/Query.js" as Q

ListView
{
    orientation: ListView.Horizontal
    clip: true

    signal tagRemoved(int index)

    model: ListModel{ ListElement{tag: "test"}}

    delegate: TagDelegate
    {
        id: delegate

        Connections
        {
            target: delegate
            onRemoveTag: tagRemoved(index)
        }
    }

    function populate(url)
    {
        console.log("trying ot get tag for ", Q.Query.picTags_.arg(url))

        model.clear()
        var tags = pix.get(Q.Query.picTags_.arg(url))

        if(tags.length > 0)
            for(var i in tags)
                model.append(tags[i])
    }
}
