import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    width: 1920
    height: 1080
    visible: true
    color: "black"

    property real bloomSizeParam: 1.0
    property real bloomStrengthParam: 1.0

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
        interval: 3000
        running: true
        onTriggered: {
            root.contentItem.grabToImage(function(result) {
                result.saveToFile("gpu_bright.png");
                Qt.quit();
            });
        }
    }
}
