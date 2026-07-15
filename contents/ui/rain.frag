#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(binding = 1) uniform sampler2D source;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float simTime;
    float fallSpeed;
    float raindropLength;
    float slant;
    float numColumns;
    float screenRows;
    float cellHeightRatio;
    int volumetric;
    int loops;
    vec4 glintColor;
    vec4 baseColor;
};

float randomFloat(float x, float y) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = x * a + y * b;
    float sn = mod(dt, 3.14159265359);
    float val = sin(sn) * c;
    return fract(val);
}

void main() {
    vec4 texColor = texture(source, qt_TexCoord0);
    if (texColor.a < 0.01) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 cell = floor(qt_TexCoord0 * vec2(numColumns, screenRows));
    float colIndex = cell.x;
    float rowIndex = cell.y; 

    // Map the current cell to WebGL's 100x80 simulation grid
    float cellWidthRatio = 1.0 / numColumns;
    float xRatio = colIndex * cellWidthRatio;
    float yRatio = rowIndex * cellHeightRatio;
    
    float webglX = xRatio * 100.0;
    float webglY = (1.0 - yRatio) * 80.0;
    
    float columnTimeOffset = randomFloat(webglX, 0.0) * 1000.0;
    float columnSpeedOffset = randomFloat(webglX + 0.1, 0.0) * 0.5 + 0.5;
    float zDepth = volumetric > 0 ? (randomFloat(webglX + 0.2, 0.0) * 0.75 + 0.25) : 1.0;

    float columnTime = columnTimeOffset + simTime * fallSpeed * columnSpeedOffset;
    float rawRainTime = (webglY * 0.01 + columnTime) / raindropLength;
    
    // wobble logic from WebGL
    float SQRT_2 = 1.4142135623730951;
    float SQRT_5 = 2.23606797749979;
    float w = rawRainTime;
    if (loops <= 0) {
        w = rawRainTime + 0.3 * sin(SQRT_2 * rawRainTime) + 0.2 * sin(SQRT_5 * rawRainTime);
    }

    float rawBrightness = 1.0 - fract(w);
    float adjustedBrightness = max(0.0, rawBrightness * 1.1 - 0.5);
    float visualBrightness = clamp(pow(adjustedBrightness, 0.6) * 1.5, 0.0, 1.0);

    // In WebGL, the cursor is the bottom-most pixel where it wraps around.
    bool isCursor = rawBrightness > 0.95;

    vec4 finalColor = vec4(0.0);
    if (isCursor) {
        finalColor = glintColor;
    } else {
        finalColor.rgb = baseColor.rgb * (visualBrightness * zDepth);
        finalColor.a = 1.0;
    }

    // Multiply by the white mask from the blur (acts as alpha coverage)
    // This perfectly matches WebGL: vec4(color, 1.0) * mask
    fragColor = finalColor * texColor.a * qt_Opacity;
}
