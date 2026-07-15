import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects

Window {
    width: 400
    height: 400
    visible: true
    color: "black"

    Rectangle {
        id: sourceItem
        width: 100
        height: 100
        x: 150
        y: 150
        color: "white"
    }

    ShaderEffectSource {
        id: hiddenSource
        sourceItem: sourceItem
        hideSource: true
        anchors.fill: parent
        visible: false
    }

    FastBlur {
        id: blurCore
        anchors.fill: parent
        source: hiddenSource
        radius: 16
        transparentBorder: true
        visible: false
    }

    FastBlur {
        id: blurGlow
        anchors.fill: parent
        source: hiddenSource
        radius: 64
        transparentBorder: true
        visible: false
    }

    ColorOverlay {
        id: tintedGlow
        anchors.fill: parent
        source: blurGlow
        color: "#2de500" // Neon green
        visible: false
    }

    Blend {
        id: combinedBloom
        anchors.fill: parent
        source: blurCore
        foregroundSource: tintedGlow
        mode: "screen"
        visible: false
    }
    
    // Final composite to screen
    Blend {
        anchors.fill: parent
        source: hiddenSource // Pretend this is rainColoredSource
        foregroundSource: combinedBloom
        mode: "screen"
    }
    
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(result) {
                result.saveToFile("test_pipeline.png");
                Qt.quit();
            });
        }
    }
}
