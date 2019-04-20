import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ImageViewer
{
    id: flick

    property int itemWidth : parent.width
    property int itemHeight : parent.height



    readonly property string currentImageSource: "file://"+model.url

    image.source : currentImageSource

    width: itemWidth
    height: itemHeight   
}
