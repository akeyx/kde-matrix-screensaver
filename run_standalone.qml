import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    title: "KDE Matrix Screensaver Standalone"
    color: "black"

    // Provide the expected environment
    property int numColumns: 80
    property int scalingMode: 1
    property int characterSize: 24
    property real animationSpeed: 1.0
    property real fallSpeed: 0.3
    property real cycleSpeed: 0.03
    property real raindropLength: 0.75
    property real slant: 0.0
    property real bloomSize: 0.4
    property real bloomStrength: 0.7
    property color cursorColor: "#2de500"
    property color backgroundColor: "#000000"
    property color glintColor: "#e7fecc"
    property bool volumetric: false
    property bool glyphFlip: false
    property int glyphRotation: 0

    property var wallpaper: ({
        configuration: root
    })

    Loader {
        anchors.fill: parent
        source: "contents/ui/main.qml"
        onLoaded: item.testProxyConfig = wallpaper.configuration
    }
}
