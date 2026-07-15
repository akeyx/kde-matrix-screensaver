import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    width: 200; height: 200; visible: true; color: "black"
    Item {
        id: src
        width: 100; height: 100
        anchors.centerIn: parent
        Rectangle { anchors.fill: parent; color: Qt.rgba(0.0, 0.02, 0.0, 0.02) }
    }
    
    ColorMatrix {
        anchors.fill: src
        source: src
        matrix: Qt.matrix4x4(
            50, 0, 0, 0,
            0, 50, 0, 0,
            0, 0, 50, 0,
            0, 0, 0, 50
        )
    }
    
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            parent.grabToImage(function(res) {
                res.saveToFile("check_matrix.png");
                Qt.quit();
            });
        }
    }
}
