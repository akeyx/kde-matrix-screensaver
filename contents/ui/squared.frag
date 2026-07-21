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
    float threshold = 0.25;
    if (col.r < threshold) col.r = 0.0;
    if (col.g < threshold) col.g = 0.0;
    if (col.b < threshold) col.b = 0.0;
    fragColor = col * qt_Opacity;
}
