from PIL import Image
import numpy as np

img0 = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/true_bloom_0.png').convert('RGB')
img1 = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/true_bloom_1.png').convert('RGB')

arr0 = np.array(img0)
arr1 = np.array(img1)
print(f"Mean 0.0: {arr0.mean()}")
print(f"Mean 1.0: {arr1.mean()}")
