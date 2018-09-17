import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

Row
{
    spacing: space.medium

    property string accentColor : highlightColor

    Maui.ToolButton
    {
        visible: !pixViewer.holder.visible
        iconColor: currentView === views.viewer? accentColor : headBarFGColor
        iconName: "image"
        onClicked: currentView = views.viewer
    }


    Maui.ToolButton
    {
        text: qsTr("Gallery")
        iconColor: currentView === views.gallery? accentColor : headBarFGColor
        iconName: "image-multiple"
        onClicked: currentView = views.gallery
    }

    Maui.ToolButton
    {
        text: qsTr("Folders")
        iconColor: currentView === views.folders? accentColor : headBarFGColor
        iconName: "image-folder-view"
        onClicked: currentView = views.folders
    }

    Maui.ToolButton
    {
        text: qsTr("Albums")
        iconColor: currentView === views.albums? accentColor : headBarFGColor
        iconName: "image-frames"
        onClicked: currentView = views.albums
    }

    Maui.ToolButton
    {
        text: qsTr("Tags")
        iconColor: currentView === views.tags? accentColor : headBarFGColor
        iconName: "tag"
        onClicked: currentView = views.tags
    }
}

