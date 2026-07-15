import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    color: "black"

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
            };
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            root.grabToImage(function(result) {
                result.saveToFile("screenshot_0.0_0.0.png");
                Qt.quit();
            });
        }
    }
}
