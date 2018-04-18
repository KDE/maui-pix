import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../db/Query.js" as Q
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../view_models"

PixGrid
{
    id: galleryViewRoot

    headerbarExit: false
    visible: true

    function populate()
    {
        clear()
        var map = pix.get(Q.Query.allPics)
        for(var i in map)
            grid.model.append(map[i])
    }
}
