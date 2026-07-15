import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 200
    height: 200
    visible: true

    Rectangle {
        id: src
        anchors.fill: parent
        color: "green"
    }
    
    Timer {
        interval: 100
        running: true
        onTriggered: {
            src.grabToImage(function(result) {
                result.saveToFile("rect_test.png");
                Qt.quit();
            });
        }
    }
}
