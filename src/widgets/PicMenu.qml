import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.maui 1.0 as Maui
import "../view_models"

PixMenu
{
    property var paths : []
    property bool isFav : false
    property bool isMultiple: false

    signal favClicked(var urls)
    signal removeClicked(var urls)
    signal shareClicked(var urls)
    signal addClicked(var urls)
    signal tagsClicked(var urls)
    signal showFolderClicked(var urls)

    Column
    {

        MenuItem
        {
            text: qsTr(isFav ? "UnFav it": "Fav it")
            onTriggered:
            {
                favClicked(paths)
                close()
            }
        }

        MenuItem
        {
            text: qsTr("Add to...")
            onTriggered:
            {
                addClicked(paths)
                close()
            }
        }

        MenuItem
        {
            text: qsTr("Tags...")
            onTriggered:
            {
                tagsClicked(paths)
                close()
            }
        }

        MenuItem
        {
            text: qsTr("Share...")
            onTriggered:
            {
                shareClicked(paths)
                close()
            }
        }

        MenuItem
        {
            text: qsTr("Remove...")
            onTriggered:
            {
                removeClicked(paths)
                close()
            }
        }

        MenuItem
        {
            text: qsTr("Show in folder...")
            enabled: !isMultiple
            onTriggered:
            {
                showFolderClicked(paths)
                close()
            }
        }

        MenuItem
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
