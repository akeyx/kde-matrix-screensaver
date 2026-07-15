import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    width: 800; height: 600; visible: true; color: "black"

    Loader {
        anchors.fill: parent
        source: "contents/ui/main.qml"
        onLoaded: {
            item.recordingEnabled = false;
            item.animationDriver = 0.5; 
            
            item.testProxyConfig = {
                version: "classic",
                font: "matrixcode",
                effect: "palette",
                scalingMode: 1,
                characterSize: 40,
                numColumns: 20,
                animationSpeed: 0.0, fallSpeed: 0.0, cycleSpeed: 0.0,
                raindropLength: 0.75, slant: 0.0,
                bloomSize: 1.0,
                bloomStrength: 1.0,
                cursorColor: "#2de500", backgroundColor: "#000000", glintColor: "#e7fecc",
                volumetric: false, glyphFlip: false, glyphRotation: 0
            };
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            root.contentItem.grabToImage(function(res) {
                res.saveToFile("static_explode.png");
                Qt.quit();
            });
        }
    }
}
