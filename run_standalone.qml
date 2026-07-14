import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 1280
    height: 720
    visible: true
    title: "KDE Matrix Screensaver Standalone"
    color: "black"

    // Provide the expected environment
    property var wallpaper: ({
        configuration: {
            numColumns: 80,
            scalingMode: 1,
            characterSize: 24,
            animationSpeed: 1.0,
            fallSpeed: 0.3,
            cycleSpeed: 0.03,
            raindropLength: 0.75,
            slant: 0.0,
            bloomSize: 0.4,
            bloomStrength: 0.7,
            cursorColor: "#2de500",
            backgroundColor: "#000000",
            glintColor: "#e7fecc",
            volumetric: false,
            glyphFlip: false,
            glyphRotation: 0
        }
    })

    Loader {
        anchors.fill: parent
        source: "contents/ui/main.qml"
    }
}
