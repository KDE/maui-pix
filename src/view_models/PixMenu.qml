import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

import "../db/Query.js" as Q
import "../widgets/views/Pix.js" as PIX

Menu
{
    id: control

    property bool isFav : false
    property int index : -1

    onOpened: isFav = dba.isFav(list.get(index).url)

    MenuItem
    {
        text: qsTr("Select")
        onTriggered: PIX.selectItem(list.get(index))
    }

    MenuSeparator{}

    MenuItem
    {
        text: qsTr(isFav ? "UnFav it": "Fav it")
        onTriggered: list.fav(index, !isFav)
    }

    MenuItem
    {
        text: qsTr("Add to...")
        onTriggered:
        {
            dialogLoader.sourceComponent = albumsDialogComponent
            dialog.show([list.get(index).url])
        }
    }

    MenuItem
    {
        text: qsTr("Tags...")
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.show([list.get(index).url])
        }
    }

    MenuItem
    {
        text: qsTr("Share...")
        onTriggered:
        {
            if(isAndroid)
                Maui.Android.shareDialog([list.get(index).url])
            else
            {
                dialogLoader.sourceComponent = shareDialogComponent
                dialog.show([list.get(index).url])
            }
        }
    }

    MenuItem
    {
        text: qsTr("Save to...")
        onTriggered:
        {
            var pic = list.get(index).url
            dialogLoader.sourceComponent= fmDialogComponent
            dialog.mode = dialog.modes.SAVE
            dialog.suggestedFileName= Maui.FM.getFileInfo(list.get(index).url).label
            dialog.show(function(paths)
            {
                if (typeof paths == 'string')
                {
                    Maui.FM.copy([Maui.FM.getFileInfo(pic)], paths)
                }else
                {
                    for(var i in paths)
                        Maui.FM.copy([Maui.FM.getFileInfo(pic)], paths[i])
                }

            });
            close()
        }
    }

    MenuItem
    {
        visible: !isAndroid
        text: qsTr("Show in folder...")
        onTriggered:
        {
            pix.showInFolder([list.get(index).url])
            close()
        }
    }

    //    Maui.MenuItem
    //    {
    //        text: qsTr("Copy")
    //        onTriggered:
    //        {
    //            Maui.Handy.copyToClipboard(paths.join(","))
    //            control.close()
    //        }
    //    }

    MenuSeparator{}


    MenuItem
    {
        text: qsTr("Remove...")
        Kirigami.Theme.textColor: dangerColor
        onTriggered:
        {
            removeDialog.open()
            close()
        }

        Maui.Dialog
        {
            id: removeDialog
            property var paths: []

            title: qsTr("Delete file?")
            acceptButton.text: qsTr("Accept")
            rejectButton.text: qsTr("Cancel")
            message: qsTr("If you are sure you want to delete the file click on Accept, otherwise click on Cancel")
            onRejected: close()
            onAccepted:
            {
                list.deleteAt(index)
                close()
            }
        }
    }

}
