import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 200; height: 200; visible: true; color: "black"
    
    Item {
        id: src
        width: 100; height: 100
        Rectangle { anchors.fill: parent; color: "white" }
    }
    
    Item {
        id: bg
        width: 100; height: 100
        Rectangle { anchors.fill: parent; color: "black" }
    }
    
    Item {
        id: strengthRectContainer
        anchors.fill: src
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0.25, 0.25, 0.25, 1.0) // 0.25 brightness
        }
    }

    ShaderEffectSource {
        id: strengthSrc
        sourceItem: strengthRectContainer
        hideSource: true
        anchors.fill: strengthRectContainer
    }

    Item {
        id: dimmedContainer
        anchors.fill: src
        Blend {
            anchors.fill: parent
            source: src
            foregroundSource: strengthSrc
            mode: "multiply"
        }
    }

    ShaderEffectSource {
        id: dimmedSrc
        sourceItem: dimmedContainer
        hideSource: true
        anchors.fill: dimmedContainer
    }

    Blend {
        id: finalBlend
        anchors.fill: src
        source: bg // <--- NOW IT BLENDS ON TOP OF BLACK!
        foregroundSource: dimmedSrc
        mode: "screen"
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            finalBlend.grabToImage(function(res) {
                res.saveToFile("check_multiply_fixed2.png");
                Qt.quit();
            });
        }
    }
}
