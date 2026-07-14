import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: rootWindow
    visible: true
    width: 400; height: 400
    
    // Simulate the config variables
    property int cfg_scalingMode: 1
    
    // Simulate testWin
    property int scalingMode: cfg_scalingMode
    
    // Simulate the wallpaper proxy
    property var wallpaper: ({
        configuration: this
    })
    
    Text {
        anchors.centerIn: parent
        text: "Mode: " + wallpaper.configuration.scalingMode
        onTextChanged: Qt.exit(42)
    }
    
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            rootWindow.cfg_scalingMode += 1
            console.log("cfg_scalingMode changed to: " + rootWindow.cfg_scalingMode)
            if (rootWindow.cfg_scalingMode > 3) Qt.exit(0);
        }
    }
}
