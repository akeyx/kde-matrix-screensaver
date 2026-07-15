import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 200; height: 200; visible: true; color: "black"
    
    Item {
        id: src
        width: 100; height: 100
        Rectangle { anchors.fill: parent; color: "white" }
    }
    
    Item {
        id: dimmed
        anchors.fill: src
        opacity: 0.25
        Rectangle { anchors.fill: parent; color: "white" }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            dimmed.grabToImage(function(res) {
                res.saveToFile("check_opacity_direct.png");
                Qt.quit();
            });
        }
    }
}
