import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../../view_models"
import "../../../db/Query.js" as Q
import org.kde.mauikit 1.0 as Maui


Maui.Page
{
    property string currentQuery : ""

    headBarExitIcon: "edit-clear"
    headBarTitle: searchResults.grid.count + qsTr(" results")
    headBarVisible: true

    PixGrid
    {
        id: searchResults
        height: parent.height
        width: parent.width
        headBarVisible: false

        holder.emoji: "qrc:/img/assets/BugSearch.png"
        holder.isMask: false
        holder.title : "No Results!"
        holder.body: "Try with another query"
        holder.emojiSize: iconSizes.huge

    }

    footBar.leftContent:  Maui.ToolButton
    {
        iconName: "view-filter"
    }

    footBar.middleContent:  TextField
    {
        id: searchInput
        placeholderText: qsTr("Search...")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:  Text.AlignVCenter
        selectByMouse: !isMobile
        focus: true
        wrapMode: TextEdit.Wrap
        selectionColor: highlightColor
        selectedTextColor: highlightedTextColor
        onAccepted: runSearch(searchInput.text)
    }

    footBar.rightContent : Maui.ToolButton
    {
        iconName: "edit-clear"
        Layout.alignment: Qt.AlignRight
        onClicked: searchInput.clear()
    }

    function runSearch(query)
    {
        searchResults.clear()
        if(query)
        {
            currentQuery = query

            var queries = query.split(",")
            for(var i in queries)
            {
                var res =[]
                res.push(pix.get(Q.Query.searchFor_.arg(queries[i])))
                res.push(tag.getUrls(query, true))
                populate(res)
            }
        }
    }

    function populate(data)
    {
        if(data.length > 0)
            for(var i in data)
                searchResults.grid.model.append(data[i])
    }
}
