from PIL import Image
import numpy as np

img = Image.open('final_bloom_1.png').convert('RGB')
arr = np.array(img)
print(f"Max pixel: {arr.max()}")
print(f"Mean pixel: {arr.mean()}")
