import QtQuick
import QtQuick.Window

Window {
    width: 200; height: 200; visible: true; color: "blue"
    Rectangle {
        id: src
        width: 100; height: 100; color: "red"
        anchors.centerIn: parent
        visible: false
    }
    ShaderEffectSource {
        id: tex
        sourceItem: src
        hideSource: true
    }
    ShaderEffect {
        anchors.fill: parent
        property var source: tex
        fragmentShader: "
            #version 440
            layout(location = 0) in vec2 qt_TexCoord0;
            layout(location = 0) out vec4 fragColor;
            layout(binding = 1) uniform sampler2D source;
            void main() {
                vec4 c = texture(source, qt_TexCoord0);
                if (c.r > 0.0) fragColor = vec4(0.0, 1.0, 0.0, 1.0); // Output green if texture has red
                else fragColor = vec4(1.0, 1.0, 0.0, 1.0); // Output yellow otherwise
            }
        "
    }
}
