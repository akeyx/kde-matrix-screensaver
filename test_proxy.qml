import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    visible: true
    property int val: 10
    property var proxy: ({ inner: val })
    
    Component.onCompleted: {
        val = 20;
        console.log("proxy.inner is: " + proxy.inner)
        Qt.quit()
    }
}
