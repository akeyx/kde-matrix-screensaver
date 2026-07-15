import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 400
    height: 400
    visible: true
    color: "black"

    Rectangle {
        id: a
        width: 100; height: 100; x: 50; y: 50; color: "red"; visible: true
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(result) {
                result.saveToFile("test_blend_chain_2.png");
                Qt.quit();
            });
        }
    }
}
