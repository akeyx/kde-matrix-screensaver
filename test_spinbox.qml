import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
    visible: true
    property int cfg_val: 10
    SpinBox {
        value: cfg_val
        onValueModified: { console.log("modified"); cfg_val = value }
    }
    Component.onCompleted: Qt.quit()
}
