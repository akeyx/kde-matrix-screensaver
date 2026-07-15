import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: testWin
    width: 200
    height: 600
    visible: true
    color: "black"

    property int numColumns: 5
    property int scalingMode: 1
    property int characterSize: 40
    property real animationSpeed: 0.0 // STATIC
    property real fallSpeed: 0.0
    property real cycleSpeed: 0.0
    property real raindropLength: 0.75
    property real slant: 0.0
    property real bloomSize: 0.0
    property real bloomStrength: 0.0
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
        source: "../contents/ui/main.qml"
        onLoaded: {
            item.testProxyConfig = wallpaper.configuration;
            item.timeAnim.pause();
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            // Grab 0
            testWin.contentItem.grabToImage(function(result) { result.saveToFile("bloom_test_0.png"); });
            testWin.bloomSize = 0.333;
            testWin.bloomStrength = 0.333;
        }
    }
    Timer {
        interval: 2000
        running: true
        onTriggered: {
            testWin.contentItem.grabToImage(function(result) { result.saveToFile("bloom_test_33.png"); });
            testWin.bloomSize = 0.666;
            testWin.bloomStrength = 0.666;
        }
    }
    Timer {
        interval: 3000
        running: true
        onTriggered: {
            testWin.contentItem.grabToImage(function(result) { result.saveToFile("bloom_test_66.png"); });
            testWin.bloomSize = 1.0;
            testWin.bloomStrength = 1.0;
        }
    }
    Timer {
        interval: 4000
        running: true
        onTriggered: {
            testWin.contentItem.grabToImage(function(result) { result.saveToFile("bloom_test_100.png"); Qt.quit(); });
        }
    }
}
