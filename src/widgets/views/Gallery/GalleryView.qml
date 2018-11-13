import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../db/Query.js" as Q
import "../../../widgets/views/Viewer/Viewer.js" as VIEWER
import "../../../view_models"

PixGrid
{
    id: galleryViewRoot
    list.query: "select * from images"
    headBarExit: false
    visible: true
    holder.emoji: "qrc:/img/assets/ElectricPlug.png"
    holder.isMask: false
    holder.title : "No Pics!"
    holder.body: "Add new image sources"
    holder.emojiSize: iconSizes.huge
}
