import QtQuick 2.9
import QtQuick.Controls 2.2
import "../../../view_models"
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control
    padding:0
    title: qsTr("Tags")

    headBar.leftContent: ToolButton
    {
        icon.name: "list-add"
        onClicked: newTagDialog.open()
    }

    headBar.rightContent: ToolButton
    {
        icon.name: "list-remove"
    }

    Maui.Holder
    {
        visible: _tagsList.count === 0
        emoji: "qrc:/img/assets/Rainbow.png"
        isMask: false
        title : "No Tags!"
        body: "You can create new tags"
        emojiSize: iconSizes.huge
        z: 999
    }

    Maui.ListBrowser
    {
        id: _tagsList
        anchors.fill: parent
        anchors.margins: space.medium
        model: tagsModel
        delegate: Maui.ListDelegate
        {
            id: delegate
            label: tag
            radius: Maui.Style.radiusV

            Connections
            {
                target: delegate
                onClicked:
                {
                    _tagsList.currentIndex = index
                    currentTag = tagsList.get(index).tag
                    populateGrid(currentTag)
                }
            }
        }
    }
}


