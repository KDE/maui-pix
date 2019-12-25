import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.1 as MauiLab

import "../widgets/views/Pix.js" as PIX
import "../widgets/views/Viewer/Viewer.js" as VIEWER

MauiLab.SelectionBar
{
    id: control

    visible: count > 0 && _actionGroup.currentIndex !== views.viewer
    onExitClicked: clear()
//    colorScheme.backgroundColor: "#212121"
//    Maui.Dialog
//    {
//        id: removeDialog
//        property var paths: []

//        title: qsTr("Delete files?")
//        acceptButton.text: qsTr("Accept")
//        rejectButton.text: qsTr("Cancel")
//        message: qsTr("If you are sure you want to delete the files click on Accept, otherwise click on Cancel")
//        onRejected: close()
//        onAccepted:
//        {
//            PIX.removePics(selectedPaths)
//            control.clear()
//            close()
//        }
//    }
    listDelegate: Maui.ItemDelegate
    {
        Kirigami.Theme.inherit: true
        height: Maui.Style.toolBarHeight
        width: parent.width
        Maui.ListItemTemplate
        {
            anchors.fill: parent
            label1.text: model.title
            label2.text: model.url
            imageSource: model.url
        }

        onClicked: control.removeAtIndex(index)
    }

    Action
    {
        text: qsTr("Un/Fav")
        icon.name: "love"
        onTriggered: VIEWER.fav(selectedPaths)
    }

    Action
    {
        text: qsTr("Add to")
        icon.name: "document-save"
        onTriggered:
        {
            dialogLoader.sourceComponent = albumsDialogComponent
            dialog.show(control.selectedPaths)
        }
    }

    Action
    {
        text: qsTr("Tag")
        icon.name: "tag"
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.show(selectedPaths)
        }
    }

    Action
    {
        text: qsTr("Share")
        icon.name: "document-share"
        onTriggered:
        {
            if(isAndroid)
                Maui.Android.shareDialog(selectedPaths)
            else
            {
                dialogLoader.sourceComponent = shareDialogComponent
                dialog.show(selectedPaths)
            }
        }
    }

    Action
    {
        text: qsTr("Export")
        icon.name: "document-save"
        onTriggered:
        {
            var pics = selectedPaths
            dialogLoader.sourceComponent= fmDialogComponent
            dialog.show(function(paths)
            {
                for(var i in paths)
                    Maui.FM.copy(pics, paths[i])

            });
        }
    }

    Action
    {
        text: qsTr("Browse")
        icon.name: "folder"
        onTriggered: pix.showInFolder(selectedPaths)
    }


    Action
    {
        text: qsTr("Remove")
        icon.name: "delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
        }
    }
}

