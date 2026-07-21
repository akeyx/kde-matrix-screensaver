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
layout(binding = 2) uniform sampler2D pyr0Tex;
layout(binding = 3) uniform sampler2D pyr1Tex;
layout(binding = 4) uniform sampler2D pyr2Tex;
layout(binding = 5) uniform sampler2D pyr3Tex;
layout(binding = 6) uniform sampler2D pyr4Tex;

void main() {
    vec4 primary = texture(primaryTex, qt_TexCoord0);
    vec4 p0 = texture(pyr0Tex, qt_TexCoord0);
    vec4 p1 = texture(pyr1Tex, qt_TexCoord0);
    vec4 p2 = texture(pyr2Tex, qt_TexCoord0);
    vec4 p3 = texture(pyr3Tex, qt_TexCoord0);
    vec4 p4 = texture(pyr4Tex, qt_TexCoord0);

    // Sum the levels of the pyramid with the same weights as regl/bloomPass.combine.frag.glsl
    vec4 combinedBloom = p0 * 0.96549 +
                         p1 * 0.92832 +
                         p2 * 0.88790 +
                         p3 * 0.84343 +
                         p4 * 0.79370;

    // Apply power-of-two contrast scaling to match WebGL palette contrast and keep glow localized
    combinedBloom = pow(combinedBloom, vec4(2.0)) * 1.6;
    combinedBloom *= bloomStrength;

    // Simple additive blend
    vec4 finalResult = primary + combinedBloom;

    // Output with overall item opacity
    fragColor = finalResult * qt_Opacity;
}
