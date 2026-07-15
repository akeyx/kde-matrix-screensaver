#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float bloomStrength;
};

layout(binding = 1) uniform sampler2D primaryTex;
layout(binding = 2) uniform sampler2D blurCoreTex;
layout(binding = 3) uniform sampler2D tintedGlowTex;

void main() {
    vec4 primary = texture(primaryTex, qt_TexCoord0);
    vec4 core = texture(blurCoreTex, qt_TexCoord0);
    vec4 glow = texture(tintedGlowTex, qt_TexCoord0);

    // Additive blend for the two bloom components
    vec4 combinedBloom = min(core + glow, vec4(1.0));

    // Scale bloom by bloomStrength
    combinedBloom *= bloomStrength;

    // Screen blend primary text over the bloom
    // result = 1 - (1 - bloom) * (1 - primary)
    vec4 finalResult = primary + combinedBloom - primary * combinedBloom;

    // Output with overall item opacity
    fragColor = finalResult * qt_Opacity;
}
