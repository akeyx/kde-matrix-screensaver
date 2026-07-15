import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: testWin
    title: "Matrix Screensaver Preview"
    color: "black"
    visible: true
    width: 800
    height: 600

    property int numColumns: 80
    property int scalingMode: 1
    property int characterSize: 40
    property real animationSpeed: 1.0
    property real fallSpeed: 0.3
    property real cycleSpeed: 0.03
    property real raindropLength: 0.75
    property real slant: 0.0
    property real bloomSize: 0.4
    property real bloomStrength: 0.1
    property color cursorColor: "#2de500"
    property color backgroundColor: "#000000"
    property color glintColor: "#e7fecc"
    property bool volumetric: false
    property bool glyphFlip: false
    property int glyphRotation: 0

    property var wallpaper: ({
        configuration: testWin
    })

    Loader {
        anchors.fill: parent
        source: "contents/ui/main.qml"
        onLoaded: item.testProxyConfig = wallpaper.configuration
    }
    
    Timer {
        interval: 5000
        running: true
        onTriggered: {
            testWin.contentItem.grabToImage(function(result) {
                result.saveToFile("preview_bug_5s.png");
                Qt.quit();
            });
        }
    }
}
