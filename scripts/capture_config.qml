import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: testWin
    width: 900
    height: 700
    visible: true
    color: "#1e1e2e"
    title: "Matrix Digital Rain - Settings"

    Loader {
        anchors.fill: parent
        source: "contents/ui/config.qml"
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: {
            testWin.contentItem.grabToImage(function(result) {
                result.saveToFile("gallery_config.png");
                Qt.quit();
            });
        }
    }
}
