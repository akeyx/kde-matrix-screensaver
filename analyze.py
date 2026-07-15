import cv2
import numpy as np

img = cv2.imread('/home/a.key/Pictures/Screenshots/Screenshot_20260715_192236.png')
# The user drew arrows. Arrows are typically red, green, or some bright color.
# Let's find red/magenta/bright non-gray pixels
hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
s = hsv[:,:,1]
v = hsv[:,:,2]
# Find highly saturated pixels (the arrows)
arrows = (s > 150) & (v > 150)
coords = np.column_select(np.where(arrows))

# Where are these arrows pointing?
# We can just print out a small crop around an arrow to see what's there
if len(coords) > 0:
    cy, cx = coords[0]
    print(f"Arrow found around {cx}, {cy}")
    crop = img[max(0, cy-40):min(img.shape[0], cy+40), max(0, cx-40):min(img.shape[1], cx+40)]
    # Convert crop to ascii
    gray = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
    chars = ' .:-=+*#%@'
    for y in range(0, gray.shape[0], 2):
        line = ''
        for x in range(0, gray.shape[1], 2):
            val = gray[y, x]
            line += chars[int(val / 255.0 * 9)]
        print(line)
else:
    print("No colored arrows found.")

