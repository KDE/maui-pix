import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ImageViewer
{
    property int itemWidth : parent.width
    property int itemHeight : parent.height
    readonly property string currentImageSource: model.url

    source : currentImageSource
    imageWidth: 1000
    imageHeight: 1000
    width: itemWidth
    height: itemHeight
    animated: model.format === "gif"
}
