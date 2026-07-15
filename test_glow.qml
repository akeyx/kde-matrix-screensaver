import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 200; height: 200; visible: true; color: "black"
    Item {
        id: src
        width: 100; height: 100
        anchors.centerIn: parent
        Rectangle { width: 1; height: 80; anchors.centerIn: parent; color: "lime" }
    }
    
    ShaderEffectSource { id: s1; sourceItem: src; hideSource: true; live: true }

    Glow {
        anchors.fill: src
        source: s1
        radius: 32
        samples: 33
        color: "lime"
        spread: 0.8
    }
    
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(res) {
                res.saveToFile("check_glow.png");
                Qt.quit();
            });
        }
    }
}
