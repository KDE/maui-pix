import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

import "../widgets/views/Pix.js" as PIX
import "../widgets/views/Viewer/Viewer.js" as VIEWER

Maui.SelectionBar
{
    id: control
    Layout.fillWidth : true
    Layout.leftMargin: space.big
    Layout.rightMargin: space.big
    Layout.bottomMargin: space.big
    Layout.topMargin: space.small
    visible: selectionList.count > 0 && currentView !== views.viewer
    onIconClicked: _menu.popup()
    onExitClicked: clear()
//    colorScheme.backgroundColor: "#212121"

    Menu
    {
        id: _menu

        MenuItem
        {
            text: qsTr("Un/Fav them")
            onTriggered: VIEWER.fav(selectedPaths)
        }

        MenuItem
        {
            text: qsTr("Add to...")
            onTriggered:
            {
                dialogLoader.sourceComponent = albumsDialogComponent
                dialog.show(control.selectedPaths)
            }
        }

        MenuItem
        {
            text: qsTr("Tags...")
            onTriggered:
            {
                dialogLoader.sourceComponent = tagsDialogComponent
                dialog.show(selectedPaths)
            }
        }

        MenuItem
        {
            text: qsTr("Share...")
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

        MenuItem
        {
            text: qsTr("Save to...")
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

        MenuItem
        {
            text: qsTr("Show in folder...")
            onTriggered: pix.showInFolder(selectedPaths)
        }

        MenuSeparator{}

        MenuItem
        {
            text: qsTr("Remove...")
            Kirigami.Theme.textColor: dangerColor
            onTriggered:
            {
                removeDialog.open()
            }

            Maui.Dialog
            {
                id: removeDialog
                property var paths: []

                title: qsTr("Delete files?")
                acceptButton.text: qsTr("Accept")
                rejectButton.text: qsTr("Cancel")
                message: qsTr("If you are sure you want to delete the files click on Accept, otherwise click on Cancel")
                onRejected: close()
                onAccepted:
                {
                    PIX.removePics(selectedPaths)
                    control.clear()
                    close()
                }
            }
        }
    }
}

