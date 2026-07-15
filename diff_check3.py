from PIL import Image
import numpy as np

img = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/big_real_gpu_1_1.png').convert('RGB')
arr = np.array(img)
print(f"Max pixel: {arr.max()}")
print(f"Mean pixel: {arr.mean()}")
