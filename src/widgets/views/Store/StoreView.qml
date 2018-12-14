import QtQuick 2.0
import org.kde.mauikit 1.0 as Maui
import StoreModel 1.0
import StoreList 1.0

Item {


    StoreModel
    {
        id: model
    }

    StoreList
    {
        id: list
    }
}
