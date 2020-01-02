import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami
import org.maui.pix 1.0 as Pix
import "../db/Query.js" as Q
import "../widgets/views/Pix.js" as PIX

Menu
{
    id: control

    property bool isFav : false
    property int index : -1

    onOpened: isFav = Pix.Collection.isFav(model.get(index).url)

    MenuItem
    {
        text: qsTr("Select")
        onTriggered: PIX.selectItem(model.get(index))
    }

    MenuSeparator{}

    MenuItem
    {
        text: qsTr(isFav ? "UnFav it": "Fav it")
        onTriggered: Pix.Collection.fav(model.get(index).url)
    }

    MenuItem
    {
        text: qsTr("Tags")
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.composerList.urls = [model.get(index).url]
            dialog.open()
        }
    }

    MenuItem
    {
        text: qsTr("Share")
        onTriggered:
        {
            if(isAndroid)
                Maui.Android.shareDialog(model.get(index).url)
            else
            {
                dialogLoader.sourceComponent = shareDialogComponent
                dialog.show([model.get(index).url])
            }
        }
    }

    MenuItem
    {
        text: qsTr("Export")
        onTriggered:
        {
            var pic = model.get(index).url
            dialogLoader.sourceComponent= fmDialogComponent
            dialog.mode = dialog.modes.SAVE
            dialog.suggestedFileName= Maui.FM.getFileInfo(model.get(index).url).label
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
        text: qsTr("Show in folder")
        onTriggered:
        {
            Pix.Collection.showInFolder([model.get(index).url])
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
        text: qsTr("Remove")
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
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
            page.padding: Maui.Style.space.medium
            onRejected: close()
            onAccepted:
            {
                list.deleteAt(control.index)
                close()
            }
        }
    }

}
