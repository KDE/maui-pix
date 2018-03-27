import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../db/Query.js" as Q
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../view_models"

PixGrid
{
    id: galleryViewRoot
    visible: true
    picSize: Math.sqrt(root.width*root.height)*0.25
    picRadius: 2
    Component.onCompleted: populate()

    function populate()
    {
        var map = pix.get(Q.Query.allPics)
        for(var i in map)
            gridModel.append(map[i])
    }

    onPicClicked: VIEWER.view(pic)
}
