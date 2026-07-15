import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 800
    height: 600
    visible: true
    color: "black"

    property color testColor: "#e7fecc"

    Component.onCompleted: {
        console.log("testColor:", testColor);
        console.log("testColor.r:", testColor.r);
        Qt.quit();
    }
}
