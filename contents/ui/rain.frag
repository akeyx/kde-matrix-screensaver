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
    float numRows;
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

    vec2 cell = floor(qt_TexCoord0 * vec2(numColumns, numRows));
    float colIndex = cell.x;
    float rowIndex = cell.y; 

    float columnTimeOffset = randomFloat(colIndex, 0.0) * 1000.0;
    float columnSpeedOffset = randomFloat(colIndex + 0.1, 0.0) * 0.5 + 0.5;
    float zDepth = volumetric > 0 ? (randomFloat(colIndex + 0.2, 0.0) * 0.75 + 0.25) : 1.0;

    float columnTime = columnTimeOffset + simTime * fallSpeed * columnSpeedOffset;
    
    float cellYRatio = rowIndex * cellHeightRatio;
    
    float rawRainTime = ((1.0 - cellYRatio) * 0.5 + columnTime) / raindropLength;

    float w = rawRainTime;
    if (loops <= 0 && slant != 0.0) {
        w = rawRainTime + sin(rawRainTime * 3.14159265359) * slant;
    }
    float rawBrightness = 1.0 - fract(w);
    float adjustedBrightness = max(0.0, rawBrightness * 1.1 - 0.5);

    float rainTimeStep = (cellHeightRatio * 0.5) / raindropLength;
    float stepAmount = rainTimeStep;
    if (loops <= 0 && slant != 0.0) {
        stepAmount = rainTimeStep * max(0.1, 1.0 + cos(rawRainTime * 3.14159265359) * slant * 3.14159265359);
    }
    bool isCursor = rawBrightness > (1.0 - stepAmount);

    vec4 finalColor = vec4(0.0);
    if (isCursor) {
        finalColor = glintColor;
    } else {
        finalColor = baseColor;
        finalColor.a *= (adjustedBrightness * zDepth);
    }

    finalColor.rgb *= finalColor.a;

    fragColor = finalColor * texColor.a * qt_Opacity;
}
