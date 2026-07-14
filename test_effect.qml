import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    width: 100
    height: 100
    Glow {
        anchors.fill: parent
        source: Item { width: 50; height: 50 }
        radius: 8
        samples: 17
        color: "green"
    }
}
