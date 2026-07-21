import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "KDE Matrix Screensaver Preview"
    color: "black"

    // Mock properties expected by main.qml from Plasma wallpaper/screensaver configuration
    property double bloomSize: 0.4
    property double bloomStrength: 0.7
    property color cursorColor: "#c1ff75"
    property color backgroundColor: "#000000"
    property color glintColor: "#ffffff"
    property double raindropLength: 0.75
    property double slant: 0.0


    property double animationSpeed: 1.0
    property double fallSpeed: 0.3
    property double cycleSpeed: 0.03
    property int scalingMode: 1
    property int characterSize: 15
    property double trailBrightness: 1.0
    property double glintIntensity: 0.35
    property double cursorIntensity: 0.5

    property var wallpaper: ({
        configuration: window
    })

    Loader {
        anchors.fill: parent
        source: "../contents/ui/main.qml"
        onLoaded: {
            item.testProxyConfig = window.wallpaper.configuration;
        }
    }
}
