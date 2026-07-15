import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Window {
    width: 300; height: 300; visible: true; color: "black"

    // Transparent item with a green box
    Item {
        id: transparentContainer
        width: 100; height: 100
        x: 50; y: 50
        Rectangle { width: 50; height: 50; anchors.centerIn: parent; color: "lime" }
    }
    
    // Solid item with a green box
    Item {
        id: solidContainer
        width: 100; height: 100
        x: 200; y: 50
        Rectangle { anchors.fill: parent; color: "black" }
        Rectangle { width: 50; height: 50; anchors.centerIn: parent; color: "lime" }
    }

    ShaderEffectSource { id: tSrc; sourceItem: transparentContainer; hideSource: true; live: true }
    ShaderEffectSource { id: sSrc; sourceItem: solidContainer; hideSource: true; live: true }

    FastBlur { id: tBlur; anchors.fill: transparentContainer; source: tSrc; radius: 32 }
    FastBlur { id: sBlur; anchors.fill: solidContainer; source: sSrc; radius: 32 }

    Blend { anchors.fill: transparentContainer; source: tBlur; foregroundSource: tBlur; mode: "addition" }
    Blend { anchors.fill: solidContainer; source: sBlur; foregroundSource: sBlur; mode: "addition" }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(res) {
                res.saveToFile("check_alpha.png");
                Qt.quit();
            });
        }
    }
}
