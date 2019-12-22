import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

Maui.GridView
{
    id: albumsGridRoot

    property string currentAlbum : ""
    signal albumClicked(int index)

    adaptContent: true
    itemSize : Maui.Style.iconSizes.huge
    spacing: itemSize * 0.5 + (Kirigami.Settings.isMobile ? Maui.Style.space.big : Maui.Style.space.large)

    cellWidth: itemSize + spacing
    cellHeight: itemSize +spacing

    model: albumsModel

    delegate: AlbumDelegate
    {
        id: delegate
        albumSize : itemSize

        width: cellWidth
        height: cellHeight * 0.9

        Connections
        {
            target: delegate
            onClicked:
            {
                albumsGridRoot.currentIndex = index
                albumClicked(index)
            }
        }
    }   
}
