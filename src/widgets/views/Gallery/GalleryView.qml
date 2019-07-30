import QtQuick 2.9
import QtQuick.Controls 2.2
import "../../../view_models"

PixGrid
{
    id: galleryViewRoot
    list.query: "select * from images"
    visible: true
    holder.emoji: "qrc:/img/assets/ElectricPlug.png"
    holder.isMask: false
    holder.title : "No Pics!"
    holder.body: "Add new image sources"
    holder.emojiSize: iconSizes.huge

    function refresh()
    {
        list.refresh()
    }
}
