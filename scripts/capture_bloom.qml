import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: testWin
    width: 1920
    height: 1080
    visible: true
    color: "black"

    // Max bloom settings
    property double bloomSize: 1.0
    property double bloomStrength: 1.0
    property color cursorColor: "#2de500"
    property color backgroundColor: "#000000"
    property color glintColor: "#c1ff75"
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
                result.saveToFile("gallery_bloom.png");
                Qt.quit();
            });
        }
    }
}
