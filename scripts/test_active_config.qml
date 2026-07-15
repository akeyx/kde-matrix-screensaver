import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: testWin
    width: 200; height: 200; visible: true; color: "black"
    property real bloomSize: 0.5
    property var wallpaper: ({ configuration: testWin })

    Loader {
        id: mainLoader
        anchors.fill: parent
        source: "../contents/ui/main.qml"
        onLoaded: {
            item.testProxyConfig = testWin;
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            console.log("activeConfig.bloomSize:", mainLoader.item.activeConfig.bloomSize);
            console.log("currentBloomSize:", mainLoader.item.currentBloomSize);
            testWin.bloomSize += 0.1;
        }
    }
    Timer { interval: 3000; running: true; onTriggered: Qt.quit() }
}
