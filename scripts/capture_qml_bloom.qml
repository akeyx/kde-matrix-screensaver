import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: testWin
    width: 1280
    height: 720
    visible: true
    color: "black"

    property double bloomSize: 0.4
    property double bloomStrength: 0.7
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
        source: "../contents/ui/main.qml"
        onLoaded: {
            item.testProxyConfig = wallpaper.configuration;
        }
    }

    Timer {
        interval: 10000
        running: true
        onTriggered: {
            testWin.contentItem.grabToImage(function(result) {
                result.saveToFile("../assets/qml_bloom_current.png");
                Qt.quit();
            });
        }
    }
}
