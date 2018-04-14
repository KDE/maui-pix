import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../db/Query.js" as Q
Page
{
    contentData: PixGrid
    {
        id: searchResults
        height: parent.height
        width: parent.width
        headerbarExitIcon: "edit-clear"
        headerbarTitle: searchResults.grid.count + qsTr(" results")
        holder.message: "<h2>No results!</h2><p>Try with another query</p>"
        holder.emoji: "qrc:/img/assets/face-sleeping.png"

    }

    footer: ToolBar
    {
        position: ToolBar.Footer

        RowLayout
        {
            anchors.fill: parent
            PixButton
            {
                iconName: "view-filter"
                Layout.alignment: Qt.AlignLeft
            }

            TextField
            {
                id: searchInput
                placeholderText: qsTr("Search...")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                selectByMouse: !isMobile
                focus: true
                wrapMode: TextEdit.Wrap
                selectionColor: highlightColor
                selectedTextColor: highlightedTextColor
                onAccepted: runSearch(searchInput.text)

            }

            PixButton
            {
                iconName: "edit-clear"
                Layout.alignment: Qt.AlignRight
                onClicked: searchInput.clear()
            }
        }
    }

    function runSearch(query)
    {
        searchResults.clear()
        if(query)
        {
            console.log(query)
            searchResults.headerbarTitle = query

            var queries = query.split(",")
            for(var i in queries)
                populate(pix.get(Q.Query.searchFor_.arg(queries[i])))
        }
    }

    function populate(data)
    {

        if(data.length > 0)
            for(var i in data)
                searchResults.grid.model.append(data[i])
    }
}
