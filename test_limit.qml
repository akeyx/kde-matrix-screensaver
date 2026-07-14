import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    visible: true
    width: 800
    height: 600
    
    Repeater {
        id: cols
        model: 500
        Item {
            Repeater {
                model: 284
                Text { text: "X" }
            }
        }
    }
    
    Component.onCompleted: {
        console.log("Cols spawned: " + cols.count);
        Qt.quit();
    }
}
