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
    onExitClicked:
    {
        selectionMode = false
        clear()
    }

    listDelegate: Maui.ItemDelegate
    {
        Kirigami.Theme.inherit: true
        height: Maui.Style.toolBarHeight
        width: parent.width

        background: null

        Maui.ListItemTemplate
        {
            anchors.fill: parent
            label1.text: model.title
            label2.text: model.url
            imageSource: model.url
            iconSizeHint: height
        }

        onClicked: control.removeAtIndex(index)
    }    

    Action
    {
        text: qsTr("Un/Fav")
        icon.name: "love"
        onTriggered: VIEWER.fav(control.uris)
    }

    Action
    {
        text: qsTr("Tag")
        icon.name: "tag"
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.composerList.urls = control.uris
            dialog.open()
        }
    }

    Action
    {
        text: qsTr("Share")
        icon.name: "document-share"
        onTriggered:
        {
            dialogLoader.sourceComponent = shareDialogComponent
            dialog.urls= control.uris
            dialog.open()
        }
    }

    Action
    {
        text: qsTr("Export")
        icon.name: "document-save"
        onTriggered:
        {
            const pics = control.uris
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
        text: qsTr("Remove")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
        }
    }
}

