import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: testWin
    width: 1920
    height: 1080
    visible: true
    color: "black"

    // Blue/cyan color scheme
    property double bloomSize: 0.5
    property double bloomStrength: 0.8
    property color cursorColor: "#00b4d8"
    property color backgroundColor: "#000000"
    property color glintColor: "#caf0f8"
    property double raindropLength: 0.75
    property double slant: 0.0
    property bool volumetric: false
    property bool glyphFlip: false
    property int glyphRotation: 0
    property double animationSpeed: 1.0
    property double fallSpeed: 1.0
    property double cycleSpeed: 1.0

    property var wallpaper: ({
        configuration: testWin
    })

    Loader {
        anchors.fill: parent
        source: "contents/ui/main.qml"
        onLoaded: {
            item.testProxyConfig = wallpaper.configuration;
        }
    }

    Timer {
        interval: 3000
        running: true
        onTriggered: {
            testWin.contentItem.grabToImage(function(result) {
                result.saveToFile("gallery_blue.png");
                Qt.quit();
            });
        }
    }
}
