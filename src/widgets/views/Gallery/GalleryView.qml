import QtQuick 2.9
import QtQuick.Controls 2.5
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

PixGrid
{
    id: galleryViewRoot
    list.query: "select * from images"
    holder.emoji: "qrc:/img/assets/image-multiple.svg"
    holder.title : qsTr("No Pics!")
    holder.body: qsTr("Add new sources to browse your image collection ")
    holder.emojiSize: Maui.Style.iconSizes.huge

    function refresh()
    {
        list.refresh()
    }
}
