import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../db/Query.js" as Q
import org.kde.mauikit 1.0 as Maui


Maui.Page
{
    id: control
    property string currentQuery

    headBar.middleContent: Maui.TextField
    {
        id: searchInput
        placeholderText: qsTr("Search...")
        width: footBar.middleLayout.width * 0.9
        Layout.margins: Maui.Style.space.medium
        Layout.fillWidth: true
        onAccepted: runSearch(searchInput.text)
        onCleared: searchResults.list.clear()
    }

    PixGrid
    {
        id: searchResults

        anchors.fill: parent
        title: searchResults.grid.count + qsTr(" results")
        holder.emoji: "qrc:/img/assets/image-multiple.svg"
        holder.title : qsTr("No Results!")
        holder.body: qsTr("Try with another query")
        headBar.visible: !holder.visible
    }

    function runSearch(query)
    {
        if(query)
        {
            currentQuery = query
            searchResults.list.query = Q.Query.searchFor_.arg(currentQuery)
        }
    }
}
