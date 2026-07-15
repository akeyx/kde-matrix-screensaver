from PIL import Image, ImageChops
import numpy as np

img1 = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/real_gpu_0_0.png').convert('RGB')
img2 = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/real_gpu_1_1.png').convert('RGB')

arr1 = np.array(img1)
arr2 = np.array(img2)
print(f"Max pixel 1: {arr1.max()}")
print(f"Max pixel 2: {arr2.max()}")
print(f"Mean pixel 1: {arr1.mean()}")
print(f"Mean pixel 2: {arr2.mean()}")
