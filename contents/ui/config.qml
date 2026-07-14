import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kquickcontrols 2.0 as KQuickControls

Item {
    id: root

    // Define all config properties on the root item so KCM can bind them!
    property string cfg_version: "classic"
    property string cfg_font: "matrixcode"
    property string cfg_effect: "palette"
    property int cfg_numColumns: 80
    property int cfg_scalingMode: 1
    property int cfg_characterSize: 24
    property double cfg_animationSpeed: 1.0
    property double cfg_fallSpeed: 0.3
    property double cfg_cycleSpeed: 0.03
    property double cfg_raindropLength: 0.75
    property double cfg_slant: 0.0
    property double cfg_bloomSize: 0.4
    property double cfg_bloomStrength: 0.7
    property double cfg_ditherMagnitude: 0.05
    property double cfg_resolution: 0.75
    property color cfg_cursorColor: "#c1ff75"
    property color cfg_backgroundColor: "#000000"
    property color cfg_glintColor: "#ffffff"
    property bool cfg_volumetric: false
    property bool cfg_glyphFlip: false
    property int cfg_glyphRotation: 0
    property bool cfg_skipIntro: true
    property bool cfg_suppressWarnings: true
    property bool cfg_camera: false
    property string cfg_stripeColors: ""
    property string cfg_palette: ""

    // Helper for standalone translation fallback
    readonly property var translate: (typeof i18n !== 'undefined') ? i18n : function(x) { return x; }

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

                // Category: Style & Theme
                Kirigami.Separator {
                    Kirigami.FormData.label: translate("Presets & Style")
                    Layout.fillWidth: true
                }

                QQC2.ComboBox {
                    id: versionCombo
                    Kirigami.FormData.label: translate("Matrix Version:")
                    model: ["classic", "3d", "megacity", "operator", "nightmare", "paradise", "resurrections", "trinity", "morpheus", "bugs", "palimpsest", "twilight", "holoplay"]
                    currentIndex: Math.max(0, model.indexOf(root.cfg_version))
                    onActivated: root.cfg_version = model[currentIndex]
                }

                QQC2.ComboBox {
                    id: fontCombo
                    Kirigami.FormData.label: translate("Glyph Font:")
                    model: ["matrixcode", "resurrections", "gothic", "coptic", "huberfishA", "huberfishD", "gtarg_tenretniolleh", "gtarg_alientext", "neomatrixology"]
                    currentIndex: Math.max(0, model.indexOf(root.cfg_font))
                    onActivated: root.cfg_font = model[currentIndex]
                }

                QQC2.ComboBox {
                    id: effectCombo
                    Kirigami.FormData.label: translate("Color Effect:")
                    model: ["palette", "none", "plain", "customStripes", "stripes", "pride", "transPride", "trans", "image", "mirror"]
                    currentIndex: Math.max(0, model.indexOf(root.cfg_effect))
                    onActivated: root.cfg_effect = model[currentIndex]
                }

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
                    onValueModified: root.cfg_numColumns = value
                    visible: root.cfg_scalingMode === 0
                }

                QQC2.SpinBox {
                    Kirigami.FormData.label: translate("Character Size (px):")
                    from: 8
                    to: 256
                    value: root.cfg_characterSize
                    onValueModified: root.cfg_characterSize = value
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

                RowLayout {
                    Kirigami.FormData.label: translate("Dither Magnitude:")
                    QQC2.Slider {
                        id: ditherSlider
                        from: 0.0
                        to: 0.5
                        value: root.cfg_ditherMagnitude
                        onMoved: root.cfg_ditherMagnitude = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: ditherSlider.value.toFixed(3)
                        Layout.preferredWidth: 40
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: translate("Internal Resolution:")
                    QQC2.Slider {
                        id: resSlider
                        from: 0.1
                        to: 2.0
                        value: root.cfg_resolution
                        onMoved: root.cfg_resolution = value
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: resSlider.value.toFixed(2)
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

                QQC2.CheckBox {
                    Kirigami.FormData.label: translate("Skip Start Intro:")
                    checked: root.cfg_skipIntro
                    onToggled: root.cfg_skipIntro = checked
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: translate("Suppress WebGL Warnings:")
                    checked: root.cfg_suppressWarnings
                    onToggled: root.cfg_suppressWarnings = checked
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: translate("Enable Webcam (for Mirror):")
                    checked: root.cfg_camera
                    onToggled: root.cfg_camera = checked
                }

                QQC2.TextField {
                    id: stripeColorsText
                    Kirigami.FormData.label: translate("Stripe Colors (R,G,B,...):")
                    placeholderText: "e.g. 1,0,0,0,1,0,0,0,1"
                    text: root.cfg_stripeColors
                    onTextChanged: root.cfg_stripeColors = text
                    Layout.fillWidth: true
                }

                QQC2.TextField {
                    id: paletteText
                    Kirigami.FormData.label: translate("Custom Palette (R,G,B,%,...):")
                    placeholderText: "e.g. 0,1,0,0,0.5,1,0.5,0.5,1,1,1,1"
                    text: root.cfg_palette
                    onTextChanged: root.cfg_palette = text
                    Layout.fillWidth: true
                }
            }
        }
    }
}
