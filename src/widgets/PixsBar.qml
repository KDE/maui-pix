import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.maui 1.0 as Maui

Row
{
    spacing: space.medium

    property string accentColor : highlightColor

    Maui.ToolButton
    {
        visible: !pixViewer.holder.visible
        iconColor: currentView === views.viewer? accentColor : textColor
        iconName: "image"
        onClicked: currentView = views.viewer
    }


    Maui.ToolButton
    {
        display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        text: qsTr("Gallery")
        iconColor: currentView === views.gallery? accentColor : textColor
        iconName: "image-multiple"
        onClicked: currentView = views.gallery
    }

    Maui.ToolButton
    {
        display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        text: qsTr("Folders")
        iconColor: currentView === views.folders? accentColor : textColor
        iconName: "image-folder-view"
        onClicked: currentView = views.folders
    }

    Maui.ToolButton
    {
        display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        text: qsTr("Albums")
        iconColor: currentView === views.albums? accentColor : textColor
        iconName: "image-frames"
        onClicked: currentView = views.albums
    }

    Maui.ToolButton
    {
        display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        text: qsTr("Tags")
        iconColor: currentView === views.tags? accentColor : textColor
        iconName: "tag"
        onClicked: currentView = views.tags
    }
}

