import QtQuick 2.0
import org.kde.kirigami 2.0 as Kirigami

Kirigami.GlobalDrawer
{
    handleVisible: false
    visible: false

    y: header.height
    height: parent.height - header.height

    modal:true

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    bannerImageSource: "qrc:/img/assets/banner.png"


}
