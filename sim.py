import numpy as np
import cv2

numColumns = 80
screenRows = 40
cellHeightRatio = 1.0 / screenRows
cellWidthRatio = 1.0 / numColumns
raindropLength = 0.75

simTime = 10.0
fallSpeed = 0.3

def randomFloat(x, y):
    dt = x * 12.9898 + y * 78.233
    sn = dt % 3.14159265359
    val = np.sin(sn) * 43758.5453
    return val - np.floor(val)

def wobble(w):
    return w + 0.3 * np.sin(1.4142135 * w) + 0.2 * np.sin(2.2360679 * w)

img = np.zeros((screenRows * 10, numColumns * 10, 3), dtype=np.uint8)

for rowIndex in range(screenRows):
    for colIndex in range(numColumns):
        xRatio = colIndex * cellWidthRatio
        yRatio = rowIndex * cellHeightRatio
        webglX = xRatio * 100.0
        webglY = (1.0 - yRatio) * 80.0
        
        columnTimeOffset = randomFloat(webglX, 0.0) * 1000.0
        columnSpeedOffset = randomFloat(webglX + 0.1, 0.0) * 0.5 + 0.5
        
        columnTime = columnTimeOffset + simTime * fallSpeed * columnSpeedOffset
        rawRainTime = (webglY * 0.01 + columnTime) / raindropLength
        w = wobble(rawRainTime)
        
        rawBrightness = 1.0 - (w - np.floor(w))
        adjustedBrightness = max(0.0, rawBrightness * 1.1 - 0.5)
        visualBrightness = min(max(adjustedBrightness * 1.7, 0.0), 1.0)
        
        yRatioBelow = (rowIndex + 1.0) * cellHeightRatio
        webglYBelow = (1.0 - yRatioBelow) * 80.0
        rawRainTimeBelow = (webglYBelow * 0.01 + columnTime) / raindropLength
        wBelow = wobble(rawRainTimeBelow)
        brightnessBelow = 1.0 - (wBelow - np.floor(wBelow))
        
        isCursor = rawBrightness > brightnessBelow
        
        color = [0, 0, 0]
        if isCursor:
            color = [255, 255, 255]
        else:
            color = [0, int(visualBrightness * 255), 0]
            
        img[rowIndex*10:(rowIndex+1)*10, colIndex*10:(colIndex+1)*10] = color

cv2.imwrite('sim.png', img)
