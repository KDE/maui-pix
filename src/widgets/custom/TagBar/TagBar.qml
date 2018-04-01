import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"

Item
{
    clip : true

    property alias tagsList : tagsList

    signal addClicked()
    signal tagRemovedClicked(int index)

    RowLayout
    {
        anchors.fill: parent
        PixButton
        {
            Layout.alignment: Qt.AlignLeft

            iconName: "list-add"

            onClicked: addClicked()
        }

        TagList
        {
            id: tagsList
            Layout.leftMargin: contentMargins
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
            Layout.fillWidth: true

            onTagRemoved: tagRemovedClicked(index)
        }
    }
}
