import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.maui 1.0 as Maui

Row
{
    spacing: space.medium

    property string accentColor : pix.pixColor()

    signal viewerViewClicked()
    signal galleryViewClicked()
    signal albumsViewClicked()
    signal tagsViewClicked()
    signal foldersViewClicked()
    signal searchViewClicked()

    Maui.ToolButton
    {
        display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        text: qsTr("Gallery")
        iconColor: currentView === views.gallery? accentColor : textColor
        iconName: "image-multiple"
        onClicked: galleryViewClicked()
    }

    Maui.ToolButton
    {
        display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        text: qsTr("Folders")
        iconColor: currentView === views.folders? accentColor : textColor
        iconName: "image-folder-view"
        onClicked: foldersViewClicked()
    }

    Maui.ToolButton
    {
        display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        text: qsTr("Albums")
        iconColor: currentView === views.albums? accentColor : textColor
        iconName: "image-frames"
        onClicked: albumsViewClicked()
    }

    Maui.ToolButton
    {
        display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        text: qsTr("Tags")
        iconColor: currentView === views.tags? accentColor : textColor
        iconName: "tag"
        onClicked: tagsViewClicked()
    }
}

