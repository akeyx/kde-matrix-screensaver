import QtQuick
import QtQuick.Window

Window {
    id: root
    width: 1920
    height: 1080
    visible: true
    color: "black"

    Loader {
        id: loader
        anchors.fill: parent
        source: "run_standalone.qml"
        onLoaded: {
            console.log("Loaded run_standalone.qml");
            // Wait a bit to let it render
            timer.start();
        }
    }

    Timer {
        id: timer
        interval: 2000
        onTriggered: {
            root.contentItem.grabToImage(function(result) {
                result.saveToFile("/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/scratch/standalone_screenshot.png");
                console.log("Saved standalone screenshot");
                Qt.quit();
            });
        }
    }
}
