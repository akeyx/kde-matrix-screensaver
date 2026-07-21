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
    float volumetric;
    float loops;
    vec4 glintColor;
    vec4 baseColor;
    float trailBrightness;
    float glintIntensity;
};

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float randomFloat(float x, float y) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(vec2(x, y), vec2(a, b));
    float sn = mod(dt, 3.14159265358979323846);
    return fract(sin(sn) * c);
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
    
    float cellWidthRatio = 1.0 / numColumns;
    float xRatio = colIndex * cellWidthRatio;
    float yRatio = rowIndex * cellHeightRatio;
    
    float webglX = xRatio * 100.0;
    float webglY = (1.0 - yRatio) * 80.0;
    
    float columnTimeOffset = randomFloat(webglX, 0.0) * 1000.0;
    float columnSpeedOffset = randomFloat(webglX + 0.1, 0.0) * 0.5 + 0.5;
    float zDepth = volumetric > 0.0 ? (randomFloat(webglX + 0.2, 0.0) * 0.75 + 0.25) : 1.0;
    
    float columnTime = columnTimeOffset + simTime * fallSpeed * columnSpeedOffset * zDepth;
    float rawRainTime = (webglY * 0.01 + columnTime) / raindropLength;
    
    float SQRT_2 = 1.4142135623730951;
    float SQRT_5 = 2.23606797749979;
    
    float w = rawRainTime;
    if (loops <= 0.0) {
        w = rawRainTime + 0.3 * sin(SQRT_2 * rawRainTime) + 0.2 * sin(SQRT_5 * rawRainTime);
    }
    
    float rawBrightness = 1.0 - fract(w);
    float adjustedBrightness = max(0.0, rawBrightness * 1.1 - 0.5);
    float visualBrightness = clamp(adjustedBrightness * trailBrightness, 0.0, 1.0);
    
    float yRatioBelow = (rowIndex + 1.0) * cellHeightRatio;
    float webglYBelow = (1.0 - yRatioBelow) * 80.0;
    float rawRainTimeBelow = (webglYBelow * 0.01 + columnTime) / raindropLength;
    
    float wBelow = rawRainTimeBelow;
    if (loops <= 0.0) {
        wBelow = rawRainTimeBelow + 0.3 * sin(SQRT_2 * rawRainTimeBelow) + 0.2 * sin(SQRT_5 * rawRainTimeBelow);
    }
    float brightnessBelow = 1.0 - fract(wBelow);
    
    bool isCursor = rawBrightness > brightnessBelow;
    
    vec4 finalColor = vec4(0.0);
    if (isCursor) {
        finalColor = glintColor;
        finalColor.rgb *= finalColor.a;
    } else {
        // Generate pseudo-random glint per cell that changes when characters cycle
        // WebGL cycleSpeed is typically 0.03 (which is ~1.8 changes per sec)
        // Let's use a step time that matches the character change rate
        float stepTime = floor(simTime * 1.8);
        float cellRand = randomFloat(colIndex + 13.37, rowIndex + stepTime);
        
        // 25% chance of a glint
        float glintActive = step(0.75, cellRand); 
        
        // Glint strength is random between 0.4 and 1.0
        float glintStrength = glintActive * (fract(cellRand * 10.0) * 0.6 + 0.4);
        
        // Glint fades out with the trail brightness
        float trailGlint = glintStrength * visualBrightness;
        
        // Set alpha and color
        finalColor.a = visualBrightness;
        
        // Blend green baseColor with white glintColor before applying visualBrightness
        vec3 col = baseColor.rgb;
        col = mix(col, glintColor.rgb, glintStrength * glintIntensity * 0.7);
        col *= visualBrightness;
        
        finalColor.rgb = col * zDepth;
    }
    
    fragColor = finalColor * texColor.a * qt_Opacity;
}
