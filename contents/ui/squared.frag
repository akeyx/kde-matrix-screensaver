#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float glintIntensity;
    float cursorIntensity;
};

layout(binding = 1) uniform sampler2D sourceTex;

void main() {
    vec4 col = texture(sourceTex, qt_TexCoord0);
    
    // Save glint value from the blue channel before thresholding
    float glintVal = col.b;
    
    float threshold = 0.25;
    if (col.r < threshold) col.r = 0.0;
    if (col.g < threshold) col.g = 0.0;
    if (col.b < threshold) col.b = 0.0;
    
    // Detect cursor (white/near-white highlights) and apply cursorIntensity
    bool isCursor = (col.r > 0.8 && col.g > 0.8 && col.b > 0.8);
    if (isCursor) {
        col.rgb *= cursorIntensity;
    } else if (glintVal > 0.02) {
        // Glint cell: apply a tight, clean glintIntensity boost
        col.rgb *= (1.0 + glintIntensity * 1.5);
    }
    
    fragColor = col * qt_Opacity;
}
