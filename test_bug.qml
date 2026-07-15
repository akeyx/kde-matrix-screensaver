import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 200
    height: 200
    visible: true
    color: "black"

    Rectangle {
        id: src
        x: 50; y: 50; width: 100; height: 100
        color: Qt.rgba(0.01, 0.0, 0.0, 1.0)
        visible: false
    }

    LevelAdjust {
        id: boost
        anchors.fill: parent
        source: src
        maximumInput: Qt.rgba(0.01, 0.01, 0.01, 1.0)
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            boost.grabToImage(function(result) {
                result.saveToFile("bug_test.png");
                Qt.quit();
            });
        }
    }
}
