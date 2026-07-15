import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    id: root
    width: 600; height: 600; visible: true; color: "black"

    // SINGLE STATIC CHARACTER
    Item {
        id: container
        anchors.fill: parent
        Text {
            anchors.centerIn: parent
            text: "W"
            font.family: "monospace"
            font.pixelSize: 100
            color: "#e7fecc"
            opacity: 1.0
        }
    }

    ShaderEffectSource {
        id: softBaseSource
        sourceItem: container
        hideSource: false
        live: true
        anchors.fill: container
    }

    ShaderEffectSource {
        id: bloomSource
        sourceItem: container
        hideSource: false
        live: true
        anchors.fill: container
    }

    // Step 1: Initial small blur (radius 2)
    FastBlur { id: blur1; anchors.fill: softBaseSource; source: bloomSource; radius: 2; visible: false }
    Blend { id: b1_1; anchors.fill: softBaseSource; source: blur1; foregroundSource: blur1; mode: "addition"; visible: false }
    Blend { id: b1_2; anchors.fill: softBaseSource; source: b1_1; foregroundSource: b1_1; mode: "addition"; visible: false }
    Blend { id: b1_3; anchors.fill: softBaseSource; source: b1_2; foregroundSource: b1_2; mode: "addition"; visible: false }

    // Step 2: Medium blur on the amplified result (radius 4)
    FastBlur { id: blur2; anchors.fill: softBaseSource; source: b1_3; radius: 4; visible: false }
    Blend { id: b2_1; anchors.fill: softBaseSource; source: blur2; foregroundSource: blur2; mode: "addition"; visible: false }
    Blend { id: b2_2; anchors.fill: softBaseSource; source: b2_1; foregroundSource: b2_1; mode: "addition"; visible: false }

    // Step 3: Large blur on the second amplified result (radius 8)
    FastBlur { id: blur3; anchors.fill: softBaseSource; source: b2_2; radius: 8; visible: false }
    Blend { id: b3_1; anchors.fill: softBaseSource; source: blur3; foregroundSource: blur3; mode: "addition"; visible: false }
    Blend { id: b3_2; anchors.fill: softBaseSource; source: b3_1; foregroundSource: b3_1; mode: "addition"; visible: false }

    // Step 4: Massive aura blur on the thick result (radius 16)
    FastBlur { id: blur4; anchors.fill: softBaseSource; source: b3_2; radius: 16; visible: false }
    Blend { id: b4_1; anchors.fill: softBaseSource; source: blur4; foregroundSource: blur4; mode: "addition"; visible: false }
    Blend { id: b4_2; anchors.fill: softBaseSource; source: b4_1; foregroundSource: b4_1; mode: "addition"; visible: false }

    // Combine all stages into a single super-bloom texture
    Blend { id: sum1; anchors.fill: softBaseSource; source: b1_3; foregroundSource: b2_2; mode: "addition"; visible: false }
    Blend { id: sum2; anchors.fill: softBaseSource; source: sum1; foregroundSource: b3_2; mode: "addition"; visible: false }
    Blend { id: combinedBloom; anchors.fill: softBaseSource; source: sum2; foregroundSource: b4_2; mode: "addition"; visible: false }

    property real bloomStrength: 1.0

    BrightnessContrast {
        id: dimmedBloom
        anchors.fill: softBaseSource
        source: combinedBloom
        brightness: root.bloomStrength - 1.0
        visible: false
    }

    ShaderEffectSource {
        id: dimmedBloomSource
        sourceItem: dimmedBloom
        hideSource: true
        anchors.fill: dimmedBloom
        visible: false
    }

    Blend {
        anchors.fill: softBaseSource
        source: softBaseSource
        foregroundSource: dimmedBloom
        mode: "screen" 
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            root.contentItem.grabToImage(function(res) {
                res.saveToFile("single_char_" + root.bloomStrength + ".png");
                Qt.quit();
            });
        }
    }
}
