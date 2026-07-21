import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kquickcontrols 2.0 as KQuickControls

Item {
    id: root
    width: 600
    height: 650

    // Provide a themed background so it doesn't render as solid white when tested via raw qml-qt6
    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
        z: -1
    }

    // Define all config properties on the root item so KCM can bind them!
    property int cfg_numColumns: 80
    property int cfg_scalingMode: 1
    property int cfg_characterSize: 40
    property double cfg_animationSpeed: 1.0
    property double cfg_fallSpeed: 0.3
    property double cfg_cycleSpeed: 0.03
    property double cfg_raindropLength: 0.75
    property double cfg_slant: 0.0
    property double cfg_bloomSize: 0.4
    property double cfg_bloomStrength: 0.7
    property color cfg_cursorColor: "#c1ff75"
    property color cfg_backgroundColor: "#000000"
    property color cfg_glintColor: "#ffffff"
    property double cfg_trailBrightness: 1.0
    property bool cfg_volumetric: false
    property bool cfg_glyphFlip: false
    property int cfg_glyphRotation: 0

    // Helper for standalone translation fallback
    readonly property var translate: (typeof i18n !== 'undefined') ? i18n : function(x) { return x; }

    function resetToDefaults() {
        cfg_numColumns = 80
        cfg_scalingMode = 1
        cfg_characterSize = 40
        cfg_animationSpeed = 1.0
        cfg_fallSpeed = 0.3
        cfg_cycleSpeed = 0.03
        cfg_raindropLength = 0.75
        cfg_slant = 0.0
        cfg_bloomSize = 0.4
        cfg_bloomStrength = 0.7
        cfg_cursorColor = "#c1ff75"
        cfg_backgroundColor = "#000000"
        cfg_glintColor = "#ffffff"
        cfg_trailBrightness = 1.0
        cfg_volumetric = false
        cfg_glyphFlip = false
        cfg_glyphRotation = 0
    }

    QQC2.ScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: scrollView.availableWidth - 10
            spacing: Kirigami.Units.largeSpacing

            Kirigami.FormLayout {
                Layout.fillWidth: true
                wideMode: true

                // Category: Simulation & Grid
                Kirigami.Separator {
                    Kirigami.FormData.label: translate("Simulation Parameters")
                    Layout.fillWidth: true
                }

                QQC2.ComboBox {
                    id: scalingModeCombo
                    Kirigami.FormData.label: translate("Column Scaling Mode:")
                    model: ["Fixed Number of Columns", "Fixed Character Size (Auto-fill)"]
                    currentIndex: Math.max(0, root.cfg_scalingMode)
                    onActivated: root.cfg_scalingMode = currentIndex
                }

                QQC2.SpinBox {
                    Kirigami.FormData.label: translate("Number of Columns:")
                    from: 10
                    to: 500
                    value: root.cfg_numColumns
                    editable: true
                    onValueChanged: root.cfg_numColumns = value
                    visible: root.cfg_scalingMode === 0
                }

                QQC2.SpinBox {
                    Kirigami.FormData.label: translate("Character Size (px):")
                    from: 8
                    to: 256
                    value: root.cfg_characterSize
                    editable: true
                    onValueChanged: root.cfg_characterSize = value
                    visible: root.cfg_scalingMode === 1
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Animation Speed:")
                    QQC2.Slider {
                        id: animSpeedSlider
                        from: 0.1
                        to: 5.0
                        value: root.cfg_animationSpeed
                        onMoved: root.cfg_animationSpeed = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: animSpeedSlider.value.toFixed(2)
                        Layout.preferredWidth: 40
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Fall Speed:")
                    QQC2.Slider {
                        id: fallSpeedSlider
                        from: -2.0
                        to: 5.0
                        value: root.cfg_fallSpeed
                        onMoved: root.cfg_fallSpeed = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: fallSpeedSlider.value.toFixed(2)
                        Layout.preferredWidth: 40
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Glyph Cycle Speed:")
                    QQC2.Slider {
                        id: cycleSpeedSlider
                        from: 0.0
                        to: 1.0
                        value: root.cfg_cycleSpeed
                        onMoved: root.cfg_cycleSpeed = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: cycleSpeedSlider.value.toFixed(3)
                        Layout.preferredWidth: 40
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Raindrop Length:")
                    QQC2.Slider {
                        id: raindropLengthSlider
                        from: 0.1
                        to: 5.0
                        value: root.cfg_raindropLength
                        onMoved: root.cfg_raindropLength = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: raindropLengthSlider.value.toFixed(2)
                        Layout.preferredWidth: 40
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Rain Slant (Angle):")
                    QQC2.Slider {
                        id: slantSlider
                        from: -90.0
                        to: 90.0
                        value: root.cfg_slant
                        onMoved: root.cfg_slant = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: slantSlider.value.toFixed(1) + "°"
                        Layout.preferredWidth: 40
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Trail Brightness:")
                    QQC2.Slider {
                        id: trailBrightnessSlider
                        from: 0.5
                        to: 3.0
                        value: root.cfg_trailBrightness
                        onMoved: root.cfg_trailBrightness = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: trailBrightnessSlider.value.toFixed(2)
                        Layout.preferredWidth: 40
                    }
                }

                // Category: Colors & Rendering
                Kirigami.Separator {
                    Kirigami.FormData.label: translate("Colors & Glow")
                    Layout.fillWidth: true
                }

                KQuickControls.ColorButton {
                    Kirigami.FormData.label: translate("Cursor/Tracer Color:")
                    color: root.cfg_cursorColor
                    onColorChanged: root.cfg_cursorColor = color
                }

                KQuickControls.ColorButton {
                    Kirigami.FormData.label: translate("Background Color:")
                    color: root.cfg_backgroundColor
                    onColorChanged: root.cfg_backgroundColor = color
                }

                KQuickControls.ColorButton {
                    Kirigami.FormData.label: translate("Glint Highlight Color:")
                    color: root.cfg_glintColor
                    onColorChanged: root.cfg_glintColor = color
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Bloom Size:")
                    QQC2.Slider {
                        id: bloomSizeSlider
                        from: 0.0
                        to: 1.0
                        value: root.cfg_bloomSize
                        onMoved: root.cfg_bloomSize = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: bloomSizeSlider.value.toFixed(2)
                        Layout.preferredWidth: 40
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Bloom Strength:")
                    QQC2.Slider {
                        id: bloomStrengthSlider
                        from: 0.0
                        to: 1.0
                        value: root.cfg_bloomStrength
                        onMoved: root.cfg_bloomStrength = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: bloomStrengthSlider.value.toFixed(2)
                        Layout.preferredWidth: 40
                    }
                }

                // Category: Mode & Advanced
                Kirigami.Separator {
                    Kirigami.FormData.label: translate("Special Modes & Advanced")
                    Layout.fillWidth: true
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: translate("3D / Volumetric Rain:")
                    checked: root.cfg_volumetric
                    onToggled: root.cfg_volumetric = checked
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: translate("Flip Glyphs Horizontally:")
                    checked: root.cfg_glyphFlip
                    onToggled: root.cfg_glyphFlip = checked
                }

                QQC2.ComboBox {
                    id: rotationCombo
                    Kirigami.FormData.label: translate("Glyph Rotation:")
                    model: [0, 90, 180, 270]
                    currentIndex: Math.max(0, model.indexOf(root.cfg_glyphRotation))
                    onActivated: root.cfg_glyphRotation = model[currentIndex]
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Actions:")
                    Layout.fillWidth: true

                    QQC2.Button {
                        text: translate("Reset to Defaults")
                        icon.name: "edit-undo"
                        onClicked: {
                            root.resetToDefaults()
                        }
                    }

                    QQC2.Button {
                        text: translate("Launch Fullscreen Preview")
                        icon.name: "media-playback-start"
                        onClicked: {
                            testWindowComponent.createObject(root)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: testWindowComponent
        Window {
            id: testWin
            visible: true
            visibility: Window.FullScreen
            color: "black"
            onClosing: testWin.destroy()

            // Proxy the config settings for main.qml.
            // We define the properties directly on testWin because QML does not allow declaring new properties on inline objects.
            property int numColumns: root.cfg_numColumns
            property int scalingMode: root.cfg_scalingMode
            property int characterSize: root.cfg_characterSize
            property real animationSpeed: root.cfg_animationSpeed
            property real fallSpeed: root.cfg_fallSpeed
            property real cycleSpeed: root.cfg_cycleSpeed
            property real raindropLength: root.cfg_raindropLength
            property real slant: root.cfg_slant
            property real bloomSize: root.cfg_bloomSize
            property real bloomStrength: root.cfg_bloomStrength
            property color cursorColor: root.cfg_cursorColor
            property color backgroundColor: root.cfg_backgroundColor
            property color glintColor: root.cfg_glintColor
            property real trailBrightness: root.cfg_trailBrightness
            property bool volumetric: root.cfg_volumetric
            property bool glyphFlip: root.cfg_glyphFlip
            property int glyphRotation: root.cfg_glyphRotation

            property var wallpaper: ({
                configuration: testWin
            })

            Loader {
                anchors.fill: parent
                source: "main.qml"
                onLoaded: item.testProxyConfig = wallpaper.configuration
            }

            // Close on click or key press
            MouseArea {
                anchors.fill: parent
                onClicked: testWin.close()
            }
            Item {
                focus: true
                anchors.fill: parent
                Keys.onPressed: testWin.close()
            }
        }
    }
}
