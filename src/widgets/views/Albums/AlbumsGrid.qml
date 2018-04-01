import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3


GridView
{
    id: albumsGridRoot
    property int gridSize : 64

    signal albumClicked(int index)

    clip: true

    width: parent.width
    height: parent.height

    cellHeight: gridSize*2
    cellWidth: gridSize*2

    focus: true

    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.AutoFlickDirection
    snapMode: GridView.SnapToRow

    model: ListModel
    {
        id: gridModel

        ListElement{album: "Favs"}
        ListElement{album: "Recent"}
    }

    highlightFollowsCurrentItem: true

    delegate: AlbumDelegate
    {
        id: delegate
        albumSize : 48

        Connections
        {
            target: delegate
            onClicked: albumClicked(index)
        }
    }

    ScrollBar.vertical: ScrollBar{ visible: true}

}
