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
    
    Item {
        id: effContainer
        anchors.fill: src
        // NO visible: false!
        MultiEffect {
            anchors.fill: parent
            source: src
            blurEnabled: true
            blur: 1.0
            blurMax: 32
            shadowEnabled: true
            shadowBlur: 1.0
            shadowColor: "lime"
        }
    }

    ShaderEffectSource {
        id: effSrc
        sourceItem: effContainer
        hideSource: true
        anchors.fill: effContainer
    }

    // Try blending with the effect container!
    Blend {
        anchors.fill: src
        source: src
        foregroundSource: effSrc 
        mode: "screen"
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(res) {
                res.saveToFile("check_multi_container.png");
                Qt.quit();
            });
        }
    }
}
