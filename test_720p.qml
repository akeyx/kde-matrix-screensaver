import QtQuick
import QtQuick.Window

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    color: "black"

    Loader {
        id: loader
        anchors.fill: parent
        source: "contents/ui/main.qml"
        onLoaded: {
            timer.start();
        }
    }

    Timer {
        id: timer
        interval: 2000
        onTriggered: {
            root.contentItem.grabToImage(function(result) {
                result.saveToFile("/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/scratch/test_720p.png");
                Qt.quit();
            });
        }
    }
}
