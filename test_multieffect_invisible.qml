import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Window {
    width: 200; height: 200; visible: true; color: "black"
    Item {
        id: src
        width: 100; height: 100
        anchors.centerIn: parent
        Rectangle { width: 1; height: 80; anchors.centerIn: parent; color: "lime" }
    }
    
    MultiEffect {
        id: eff
        anchors.fill: src
        source: src
        blurEnabled: true
        blur: 1.0
        blurMax: 32
        shadowEnabled: true
        shadowBlur: 1.0
        shadowColor: "lime"
        visible: false
    }

    // Try blending with the invisible effect!
    Blend {
        anchors.fill: src
        source: src
        foregroundSource: eff // directly from effect
        mode: "screen"
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(res) {
                res.saveToFile("check_multi_invisible.png");
                Qt.quit();
            });
        }
    }
}
