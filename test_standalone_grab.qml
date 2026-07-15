import QtQuick
import QtQuick.Window

Window {
    id: win
    width: 1280
    height: 720
    visible: true
    color: "black"

    Loader {
        id: loader
        anchors.fill: parent
        source: "contents/ui/main.qml"
        onLoaded: {
            item.recordingEnabled = false
            item.testProxyConfig = {
                version: "classic",
                font: "matrixcode",
                effect: "palette",
                scalingMode: 1,
                characterSize: 24,
                numColumns: 80,
                animationSpeed: 1.0,
                fallSpeed: 0.3,
                cycleSpeed: 0.03,
                raindropLength: 0.75,
                slant: 0.0,
                bloomSize: 0.0,
                bloomStrength: 0.0,
                cursorColor: "#2de500",
                backgroundColor: "#000000",
                glintColor: "#e7fecc",
                volumetric: false,
                glyphFlip: false,
                glyphRotation: 0
            }
            timer.start();
        }
    }

    Timer {
        id: timer
        interval: 3000
        onTriggered: {
            win.contentItem.grabToImage(function(result) {
                result.saveToFile("/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/scratch/standalone_output.png");
                Qt.quit();
            });
        }
    }
}
