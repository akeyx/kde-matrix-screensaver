import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 800
    height: 600
    visible: true
    Loader {
        anchors.fill: parent
        source: "contents/ui/config.qml"
        onLoaded: {
            console.log("Launching preview...");
            // Click the button! Or just call createObject directly!
            // In config.qml there is `testWindowComponent`
            let component = null;
            for (let i = 0; i < item.children.length; i++) {
                if (item.children[i].toString().indexOf("testWindowComponent") !== -1) {
                    component = item.children[i];
                    break;
                }
            }
            if (!component) {
                // If we can't find it, we can just call showFullScreen on the created object
                // Let's just find the QQC2 Button and click it!
                // Or better, let's just create it directly via C++
            }
        }
    }
}
