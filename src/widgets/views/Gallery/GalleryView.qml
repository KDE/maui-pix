import QtQuick 2.9
import QtQuick.Controls 2.5
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

PixGrid
{
    id: galleryViewRoot
    list.query: "select * from images"
    visible: true
    holder.emoji: "qrc:/img/assets/image-multiple.svg"
    holder.isMask: false
    holder.title : "No Pics!"
    holder.body: "Add new image sources"
    holder.emojiSize: Maui.Style.iconSizes.huge

    function refresh()
    {
        list.refresh()
    }
}
