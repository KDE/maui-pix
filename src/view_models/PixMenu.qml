import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import "../db/Query.js" as Q
import "../widgets/views/Pix.js" as PIX

Maui.Menu
{
    id: control

    property bool isFav : false

    onOpened:
    {
        console.log(grid.currentIndex, "checking if is fav",list.get(grid.currentIndex).fav)
        isFav = list.get(grid.currentIndex).fav == 0 ? false : true
    }

    Maui.MenuItem
    {
        text: qsTr(isFav ? "UnFav it": "Fav it")
        onTriggered:
        {
            list.fav(grid.currentIndex, !isFav)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Add to...")
        onTriggered:
        {
            addClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Tags...")
        onTriggered:
        {
            tagsClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Share...")
        onTriggered:
        {
            shareClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Remove...")
        onTriggered:
        {
            removeClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Show in folder...")
        enabled: !isMultiple
        onTriggered:
        {
            showFolderClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Save to...")
        onTriggered:
        {
            var pic = picUrl
            fmDialog.show(function(paths)
            {
                for(var i in paths)
                    Maui.FM.copy([pic], paths[i])

            });
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Copy")
        onTriggered:
        {
            Maui.Handy.copyToClipboard(paths.join(","))
            control.close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Select")
        onTriggered:
        {
            for(var i in paths)
                PIX.selectItem(dba.get(Q.Query.picUrl_.arg(paths[i]))[i])

            control.close()
        }
    }  
}
