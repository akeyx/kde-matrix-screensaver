import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 800
    height: 600
    visible: true
    color: "black"

    property real bloomStrength: 0.1

    Rectangle {
        id: rainColored
        width: 100; height: 100; x: 150; y: 150; color: "white"; visible: false
    }

    ShaderEffectSource {
        id: rainColoredSource
        sourceItem: rainColored
        hideSource: true
        anchors.fill: rainColored
    }

    Rectangle {
        id: squaredContainer
        width: 100; height: 100; x: 100; y: 100; color: "green"; visible: false
    }

    ShaderEffectSource {
        id: squaredSource
        sourceItem: squaredContainer
        hideSource: true
        anchors.fill: squaredContainer
        visible: false
    }

    FastBlur {
        id: blurCore
        anchors.fill: parent
        source: squaredSource
        radius: 16
        transparentBorder: true
        visible: false
        opacity: bloomStrength
    }

    FastBlur {
        id: blurGlow
        anchors.fill: parent
        source: squaredSource
        radius: 64
        transparentBorder: true
        visible: false
    }

    ColorOverlay {
        id: tintedGlow
        anchors.fill: parent
        source: blurGlow
        color: "lime"
        visible: false
        opacity: bloomStrength
    }

    Blend {
        id: combinedBloom
        anchors.fill: parent
        source: blurCore
        foregroundSource: tintedGlow
        mode: "screen"

        layer.enabled: true
        layer.effect: Component {
            Blend {
                foregroundSource: rainColoredSource
                mode: "screen"
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(result) {
                result.saveToFile("test_opacity_fix.png");
                Qt.quit();
            });
        }
    }
}
