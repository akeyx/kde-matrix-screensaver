import QtQuick
import QtQuick.Window

Window {
    width: 200; height: 200; visible: true; color: "blue"
    Rectangle {
        id: src
        width: 100; height: 100; color: "red"
        anchors.centerIn: parent
    }
    ShaderEffectSource {
        sourceItem: src
        hideSource: true
        visible: false // hide the ShaderEffectSource itself
    }
}
