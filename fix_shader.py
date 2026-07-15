import re

with open('contents/ui/rain.frag', 'r') as f:
    content = f.read()

# Replace the cursor and color logic
old_logic = """
    // In WebGL, the cursor is the bottom-most pixel where it wraps around.
    bool isCursor = rawBrightness > 0.95;

    vec4 finalColor = vec4(0.0);
    if (isCursor) {
        finalColor = glintColor;
    } else {
        finalColor.rgb = baseColor.rgb * (visualBrightness * zDepth);
        finalColor.a = 1.0;
    }
"""

new_logic = """
    // To find the exact cursor, we calculate the brightness of the cell below us
    float yRatioBelow = (rowIndex + 1.0) * cellHeightRatio;
    float webglYBelow = (1.0 - yRatioBelow) * 80.0;
    float rawRainTimeBelow = (webglYBelow * 0.01 + columnTime) / raindropLength;
    float wBelow = rawRainTimeBelow;
    if (loops <= 0) {
        wBelow = rawRainTimeBelow + 0.3 * sin(SQRT_2 * rawRainTimeBelow) + 0.2 * sin(SQRT_5 * rawRainTimeBelow);
    }
    float brightnessBelow = 1.0 - fract(wBelow);
    
    // The cursor is exactly where the brightness wraps around (current cell is bright, cell below is dark)
    bool isCursor = rawBrightness > brightnessBelow;

    vec4 finalColor = vec4(0.0);
    if (isCursor) {
        finalColor = glintColor;
        // ensure premultiplied alpha
        finalColor.rgb *= finalColor.a;
    } else {
        // Fix: Use visualBrightness as alpha to prevent black boxes occluding the background
        finalColor.a = visualBrightness;
        finalColor.rgb = baseColor.rgb * (visualBrightness * zDepth);
    }
"""

if old_logic.strip() in content:
    content = content.replace(old_logic.strip(), new_logic.strip())
else:
    print("Could not find old logic to replace!")

with open('contents/ui/rain.frag', 'w') as f:
    f.write(content)
