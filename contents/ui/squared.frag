#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float glintIntensity;
    float cursorIntensity;
    vec4 glintColor;
};

layout(binding = 1) uniform sampler2D sourceTex;

void main() {
    vec4 col = texture(sourceTex, qt_TexCoord0);
    
    // Save glint value from the original channels before thresholding
    float glintVal = col.b;
    
    float threshold = 0.25;
    if (col.r < threshold) col.r = 0.0;
    if (col.g < threshold) col.g = 0.0;
    if (col.b < threshold) col.b = 0.0;
    
    // Color direction similarity to glintColor (which represents the cursor color)
    // Add small epsilon to prevent normalize division by zero
    vec3 normCol = normalize(col.rgb + vec3(0.001));
    vec3 normGlint = normalize(glintColor.rgb + vec3(0.001));
    float similarity = dot(normCol, normGlint);
    
    // Smooth cursor boost based on color similarity to avoid boxy/squary artifacts
    // and correctly match the cursor independent of color choice
    float cursorFactor = smoothstep(0.95, 0.99, similarity);
    
    if (cursorFactor > 0.01) {
        col.rgb *= (1.0 + cursorFactor * (cursorIntensity - 1.0));
    } else if (glintVal > 0.02) {
        // Glint cell: apply a tight, clean glintIntensity boost
        col.rgb *= (1.0 + glintIntensity * 1.5);
    }
    
    fragColor = col * qt_Opacity;
}
