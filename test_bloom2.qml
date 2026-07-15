import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects

Window {
    width: 400
    height: 400
    visible: true
    color: "black"

    Rectangle {
        id: sourceItem
        width: 100
        height: 100
        x: 150
        y: 150
        color: "white"
    }

    ShaderEffectSource {
        id: hiddenSource
        sourceItem: sourceItem
        hideSource: true
        anchors.fill: parent
        visible: false
    }

    DropShadow {
        anchors.fill: parent
        source: hiddenSource
        radius: 32
        samples: 65
        color: "#e7fecc"
        transparentBorder: true
    }
    
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(result) {
                result.saveToFile("test_bloom2.png");
                Qt.quit();
            });
        }
    }
}
