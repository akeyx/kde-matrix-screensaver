import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 400; height: 200; visible: true; color: "black"

    // Original thin line
    Item {
        id: src1
        width: 200; height: 200; x: 0
        Rectangle { width: 2; height: 100; anchors.centerIn: parent; color: "lime" }
    }
    
    // Boosted thin line
    Item {
        id: src2
        width: 200; height: 200; x: 200
        Rectangle { width: 2; height: 100; anchors.centerIn: parent; color: "lime" }
    }

    ShaderEffectSource { id: s1; sourceItem: src1; hideSource: true; live: true }
    ShaderEffectSource { id: s2; sourceItem: src2; hideSource: true; live: true }

    // Path 1: Blur then Boost
    FastBlur { id: b1; anchors.fill: src1; source: s1; radius: 32; visible: false }
    Blend { id: boost1_1; anchors.fill: src1; source: b1; foregroundSource: b1; mode: "addition"; visible: false }
    Blend { id: boost1_2; anchors.fill: src1; source: boost1_1; foregroundSource: boost1_1; mode: "addition"; visible: false }
    Blend { id: boost1_3; anchors.fill: src1; source: boost1_2; foregroundSource: boost1_2; mode: "addition"; visible: false }
    Blend { id: boost1_4; anchors.fill: src1; source: boost1_3; foregroundSource: boost1_3; mode: "addition" }

    // Path 2: Boost then Blur then Boost
    Blend { id: preBoost2_1; anchors.fill: src2; source: s2; foregroundSource: s2; mode: "addition"; visible: false }
    Blend { id: preBoost2_2; anchors.fill: src2; source: preBoost2_1; foregroundSource: preBoost2_1; mode: "addition"; visible: false }
    Blend { id: preBoost2_3; anchors.fill: src2; source: preBoost2_2; foregroundSource: preBoost2_2; mode: "addition"; visible: false }
    
    FastBlur { id: b2; anchors.fill: src2; source: preBoost2_3; radius: 32; visible: false }
    
    Blend { id: boost2_1; anchors.fill: src2; source: b2; foregroundSource: b2; mode: "addition"; visible: false }
    Blend { id: boost2_2; anchors.fill: src2; source: boost2_1; foregroundSource: boost2_1; mode: "addition"; visible: false }
    Blend { id: boost2_3; anchors.fill: src2; source: boost2_2; foregroundSource: boost2_2; mode: "addition"; visible: false }
    Blend { id: boost2_4; anchors.fill: src2; source: boost2_3; foregroundSource: boost2_3; mode: "addition" }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(res) {
                res.saveToFile("check_thin.png");
                Qt.quit();
            });
        }
    }
}
