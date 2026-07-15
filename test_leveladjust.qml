import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 200
    height: 200
    visible: true

    Rectangle {
        id: src
        anchors.fill: parent
        color: Qt.rgba(0.1, 0.1, 0.1, 1.0)
    }
    
    LevelAdjust {
        id: boost
        anchors.fill: parent
        source: src
        minimumInput: "#000000"
        maximumInput: Qt.rgba(0.1, 0.1, 0.1, 1.0)
    }

    Timer {
        interval: 100
        running: true
        onTriggered: {
            boost.grabToImage(function(result) {
                result.saveToFile("level_test.png");
                Qt.quit();
            });
        }
    }
}
