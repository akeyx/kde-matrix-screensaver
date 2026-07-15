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
        id: blackBgWrapper
        anchors.fill: src
        Rectangle { anchors.fill: parent; color: "black" }
    }
    ShaderEffectSource {
        id: blackBg
        sourceItem: blackBgWrapper
        hideSource: true
        anchors.fill: blackBgWrapper
    }
    
    Blend {
        id: invisibleBlend
        anchors.fill: src
        source: src
        foregroundSource: blackBg
        mode: "multiply" // white * black = BLACK
        visible: false
    }

    Blend {
        id: finalBlend
        anchors.fill: src
        source: src
        foregroundSource: invisibleBlend 
        mode: "screen" // white screen BLACK = white; white screen WHITE = white (Wait!)
    }
    // Better test: src is black, invisibleBlend is white!
}
