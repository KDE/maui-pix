import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui

import "../../../view_models"

//import CloudList 1.0
import FMList 1.0
import FMModel 1.0


PixGrid
{
    id: galleryViewRoot
    headBarExit: false
    visible: true
    holder.emoji: "qrc:/img/assets/ElectricPlug.png"
    holder.isMask: false
    holder.title : "No Pics!"
    holder.body: "Add new image sources"
    holder.emojiSize: iconSizes.huge

FMModel
{
    id: _cloudModel
    list: _cloudList
}

FMList
{
    id: _cloudList
}

grid.model: _cloudModel

//    property alias list : _cloudList




//    model.list: _cloudList
//        CloudList
//    {
//id: _cloudList
//    }

}
