import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    visible: true
    Component.onCompleted: {
        var c = Qt.color("#2de500")
        console.log("hsl: ", c.hslHue, c.hslSaturation, c.hslLightness)
        Qt.quit()
    }
}
