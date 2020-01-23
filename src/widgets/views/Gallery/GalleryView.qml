import QtQuick.Controls 2.10
import QtQuick 2.10
import QtQuick.Layouts 1.3

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
