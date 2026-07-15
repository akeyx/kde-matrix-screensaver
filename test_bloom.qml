import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    width: 200; height: 200
    color: "black"

    property real testVal: 0.1
    NumberAnimation on testVal {
        from: 0.1
        to: 1.0
        duration: 2000
        loops: Animation.Infinite
    }

    Rectangle {
        id: sourceRect
        width: 100; height: 100
        anchors.centerIn: parent
        color: "red"
        visible: false
    }

    Rectangle {
        id: mask
        anchors.fill: sourceRect
        color: Qt.rgba(0, 0, 0, testVal)
        visible: false
        onColorChanged: console.log("Color changed to " + color)
    }

    OpacityMask {
        anchors.fill: sourceRect
        source: sourceRect
        maskSource: mask
    }
}
