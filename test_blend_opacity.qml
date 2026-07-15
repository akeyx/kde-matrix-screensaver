import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 200; height: 200; visible: true; color: "black"
    
    Item {
        id: src
        width: 100; height: 100
        Rectangle { anchors.fill: parent; color: "black" }
    }
    
    Item {
        id: container
        width: 100; height: 100
        opacity: 0.2
        Rectangle { anchors.fill: parent; color: "white" }
    }
    
    Blend {
        id: finalBlend
        anchors.fill: src
        source: src
        foregroundSource: container
        mode: "screen"
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            finalBlend.grabToImage(function(res) {
                res.saveToFile("check_blend_opacity.png");
                Qt.quit();
            });
        }
    }
}
