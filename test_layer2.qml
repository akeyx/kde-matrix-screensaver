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
        // NO opacity 0.0 here!
    }

    ShaderEffectSource {
        id: dummyHider
        sourceItem: rainColoredSource
        hideSource: true
        anchors.fill: parent
        opacity: 0.0 // Hide the dummy from the screen!
    }

    Rectangle {
        id: bloomContent
        width: 100
        height: 100
        x: 100
        y: 100
        color: "green"
    }

    ShaderEffectSource {
        id: bloomSource
        sourceItem: bloomContent
        hideSource: true
        anchors.fill: parent
        
        layer.enabled: true
        layer.effect: Component {
            Blend {
                foregroundSource: rainColoredSource // Reads full opacity blue!
                mode: "screen"
            }
        }
    }
    
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(result) {
                result.saveToFile("test_layer2.png");
                Qt.quit();
            });
        }
    }
}
