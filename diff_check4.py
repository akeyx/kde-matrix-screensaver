from PIL import Image
import numpy as np

img0 = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/big_real_gpu3_0_0.png').convert('RGB')
img1 = Image.open('/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/big_real_gpu3_1_1.png').convert('RGB')

print(f"Mean 0.0: {np.array(img0).mean()}")
print(f"Mean 1.0: {np.array(img1).mean()}")
