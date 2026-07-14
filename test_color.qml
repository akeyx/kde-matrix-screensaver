import QtQuick 2.15
Rectangle {
    width:100; height:100; color:"black"
    property color c: "#c1ff75"
    Component.onCompleted: {
        console.log("r=" + c.r + " g=" + c.g + " b=" + c.b)
        Qt.quit()
    }
}
