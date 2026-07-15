import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects

Window {
    width: 400
    height: 400
    visible: true
    color: "black"

    Rectangle {
        id: baseImage
        width: 100
        height: 100
        x: 150
        y: 150
        color: "blue"
    }

    ShaderEffectSource {
        id: rainColoredSource
        sourceItem: baseImage
        hideSource: true
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: dummyHider
        sourceItem: rainColoredSource
        hideSource: true
        anchors.fill: parent
        opacity: 0.0 // Hide rainColoredSource from drawing naturally, while preserving its opacity for Blend!
    }

    Rectangle {
        id: bloomContent
        width: 100
        height: 100
        x: 100
        y: 100
        color: "green"
    }
    
    FastBlur {
        id: fakeBlur
        source: bloomContent
        radius: 0
        visible: false
        opacity: 0.1 // VERY FAINT GREEN!
    }

    ShaderEffectSource {
        id: bloomSource
        sourceItem: fakeBlur
        hideSource: true
        anchors.fill: parent
        
        layer.enabled: true
        layer.effect: Component {
            Blend {
                foregroundSource: rainColoredSource
                mode: "screen"
            }
        }
    }
    
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(result) {
                result.saveToFile("test_opacity.png");
                Qt.quit();
            });
        }
    }
}
