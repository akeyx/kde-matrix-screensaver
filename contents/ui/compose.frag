#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float bloomStrength;
    vec4 glintColor;
};

layout(binding = 1) uniform sampler2D primaryTex;
layout(binding = 2) uniform sampler2D blurCoreTex;
layout(binding = 3) uniform sampler2D blurGlowTex;

void main() {
    vec4 primary = texture(primaryTex, qt_TexCoord0);
    vec4 core = texture(blurCoreTex, qt_TexCoord0);
    vec4 glow = texture(blurGlowTex, qt_TexCoord0);
    glow.rgb *= glintColor.rgb;
    glow.a *= glintColor.a;

    // Combine the two bloom components
    vec4 combinedBloom = (core + glow) * bloomStrength;

    // Simple additive blend (matching WebGL original: primary + bloom)
    vec4 finalResult = primary + combinedBloom;

    // Output with overall item opacity
    fragColor = finalResult * qt_Opacity;
}
