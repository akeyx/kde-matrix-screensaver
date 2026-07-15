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

    Item {
        id: intenseBloomContainer
        anchors.fill: parent
        FastBlur {
            anchors.fill: parent
            source: sourceItem
            radius: 32
            transparentBorder: true
        }
    }

    ShaderEffectSource {
        id: dimmedBloomSrc
        sourceItem: intenseBloomContainer
        hideSource: true
        anchors.fill: parent
        opacity: 0.0 // THIS IS THE MAGIC FIX!
    }

    Blend {
        anchors.fill: parent
        source: sourceItem
        foregroundSource: dimmedBloomSrc
        mode: "screen"
    }
    
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(result) {
                result.saveToFile("test_multi.png");
                Qt.quit();
            });
        }
    }
}
