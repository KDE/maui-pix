import QtQuick.Controls 2.10
import QtQuick 2.10
import QtQuick.Layouts 1.3
import org.maui.pix 1.0 as Pix
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

PixGrid
{
    id: galleryViewRoot
    list.urls: Pix.Collection.sources
    list.recursive: true
    holder.emoji: "qrc:/assets/image-multiple.svg"
    holder.title : qsTr("No Pics!")
    holder.body: qsTr("Add new sources to browse your image collection ")
    holder.emojiSize: Maui.Style.iconSizes.huge
}
