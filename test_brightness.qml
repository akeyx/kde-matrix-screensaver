import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 200; height: 200; visible: true; color: "black"
    
    Item {
        id: src
        width: 100; height: 100
        Rectangle { anchors.fill: parent; color: "white" }
    }
    
    BrightnessContrast {
        id: dimmed
        anchors.fill: src
        source: src
        brightness: -0.5 // Should drop 255 to 127
        visible: false
    }

    Blend {
        id: finalBlend
        anchors.fill: src
        source: src
        foregroundSource: dimmed // Read from invisible BrightnessContrast!
        mode: "screen"
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            finalBlend.grabToImage(function(res) {
                res.saveToFile("check_brightness.png");
                Qt.quit();
            });
        }
    }
}
