#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};

layout(binding = 1) uniform sampler2D sourceTex;

void main() {
    vec4 col = texture(sourceTex, qt_TexCoord0);
    fragColor = col * col * qt_Opacity;
}
