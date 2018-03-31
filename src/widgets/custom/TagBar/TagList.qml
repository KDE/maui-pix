import QtQuick 2.0

ListView
{
    orientation: ListView.Horizontal
    clip: true
    model: ListModel{ ListElement{tag: "test"}}

    delegate: TagDelegate
    {

    }
}
