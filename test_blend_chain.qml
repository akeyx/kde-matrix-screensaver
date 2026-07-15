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
        width: 100; height: 100; x: 50; y: 50; color: "red"; visible: false
    }
    Rectangle {
        id: b
        width: 100; height: 100; x: 100; y: 100; color: "blue"; visible: false
    }
    Rectangle {
        id: c
        width: 100; height: 100; x: 150; y: 150; color: "green"; visible: false
    }

    Blend {
        id: blend1
        anchors.fill: parent
        source: a
        foregroundSource: b
        mode: "screen"
        visible: false // IT IS FALSE
    }

    Blend {
        id: blend2
        anchors.fill: parent
        source: blend1
        foregroundSource: c
        mode: "screen"
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(result) {
                result.saveToFile("test_blend_chain.png");
                Qt.quit();
            });
        }
    }
}
