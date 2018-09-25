import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

Maui.GridView
{
    id: albumsGridRoot

    width: parent.width
    height: parent.height

    property string currentAlbum : ""
    signal albumClicked(int index)

    adaptContent: true

    itemSize : iconSizes.huge
    spacing: itemSize * 0.5 + (isMobile ? space.big : space.large)

    cellWidth: itemSize + spacing
    cellHeight: itemSize +spacing

    model: ListModel
    {
        id: gridModel
    }

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
