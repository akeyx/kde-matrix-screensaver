cd /home/a.key/projects/a.key/kde/kde-matrix-screensaver

cat << 'QML' > generate_comparison.qml
import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    width: 1920
    height: 1080
    visible: true
    color: "black"

    property real bloomSizeParam: 0.0
    property real bloomStrengthParam: 0.0

    Loader {
        anchors.fill: parent
        source: "contents/ui/main.qml"
        onLoaded: {
            item.recordingEnabled = false;
            item.testProxyConfig = {
                version: "classic",
                font: "matrixcode",
                effect: "palette",
                scalingMode: 1,
                characterSize: 40,
                numColumns: 80,
                animationSpeed: 1.0,
                fallSpeed: 0.3,
                cycleSpeed: 0.03,
                raindropLength: 0.75,
                slant: 0.0,
                bloomSize: root.bloomSizeParam,
                bloomStrength: root.bloomStrengthParam,
                cursorColor: "#2de500",
                backgroundColor: "#000000",
                glintColor: "#e7fecc",
                volumetric: false,
                glyphFlip: false,
                glyphRotation: 0
            };
        }
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: {
            root.contentItem.grabToImage(function(result) {
                result.saveToFile("/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/real_gpu_bloom_" + root.bloomSizeParam + ".png");
                Qt.quit();
            });
        }
    }
}
QML

export DISPLAY=:0

# 1. No Bloom
sed -i 's/bloomSizeParam: 1.0/bloomSizeParam: 0.0/; s/bloomStrengthParam: 1.0/bloomStrengthParam: 0.0/' generate_comparison.qml
qml-qt6 generate_comparison.qml

# 2. Max Bloom
sed -i 's/bloomSizeParam: 0.0/bloomSizeParam: 1.0/; s/bloomStrengthParam: 0.0/bloomStrengthParam: 1.0/' generate_comparison.qml
qml-qt6 generate_comparison.qml

