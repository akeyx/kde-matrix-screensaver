from PIL import Image, ImageChops
import numpy as np

img1 = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/screenshot_0_0.png').convert('RGB')
img2 = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/screenshot_1_1.png').convert('RGB')

diff = ImageChops.difference(img1, img2)
arr = np.array(diff)
print(f"Max difference: {arr.max()}")
print(f"Average difference: {arr.mean()}")
