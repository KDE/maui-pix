import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import "../db/Query.js" as Q
import "../widgets/views/Pix.js" as PIX
import "../view_models"

Maui.Menu
{
    id: control
    property var paths : []
    property bool isFav : false
    property bool isMultiple: false

    signal favClicked(var urls)
    signal removeClicked(var urls)
    signal shareClicked(var urls)
    signal addClicked(var urls)
    signal tagsClicked(var urls)
    signal showFolderClicked(var urls)


    Maui.MenuItem
    {
        text: qsTr(isFav ? "UnFav it": "Fav it")
        onTriggered:
        {
            favClicked(paths)
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
        enabled: !isMultiple
        text: qsTr("Select")
        onTriggered:
        {
            for(var i in paths)
                PIX.selectItem(pix.get(Q.Query.picUrl_.arg(paths[i]))[i])

            control.close()
        }
    }


    function show(url)
    {
        paths = [url]
        isMultiple = false
        isFav = pix.isFav(url)
        if(isMobile) open()
        else popup()
    }

    function showMultiple(urls)
    {
        paths = urls
        isMultiple = true
        if(isMobile) open()
        else popup()
    }
}
