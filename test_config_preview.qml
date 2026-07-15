import QtQuick 2.15
import QtQuick.Window 2.15
import QtQml 2.15

Window {
    width: 800
    height: 600
    visible: true
    Loader {
        id: configLoader
        anchors.fill: parent
        source: "contents/ui/config.qml"
        onLoaded: {
            console.log("Config loaded. Finding testWin...");
            // Simulate button click to launch preview!
            // But testWin is inside root. We can just find it by type or objectName.
            // In config.qml, testWin is a direct child of the root Item!
            let win = item.children[1]; // testWin is usually the second child!
            if (win && win.showFullScreen) {
                console.log("Found testWin, showing it!");
                win.showFullScreen();
                
                // Grab after 3 seconds
                timer.targetWin = win;
                timer.start();
            } else {
                console.log("Could not find testWin. win:", win);
                Qt.quit();
            }
        }
    }
    Timer {
        id: timer
        interval: 3000
        running: false
        property var targetWin
        onTriggered: {
            console.log("Grabbing window...");
            targetWin.contentItem.grabToImage(function(result) {
                result.saveToFile("config_preview_screenshot.png");
                console.log("Saved config_preview_screenshot.png");
                Qt.quit();
            });
        }
    }
}
