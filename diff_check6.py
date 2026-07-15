from PIL import Image
import numpy as np

img = Image.open('gpu_bright.png').convert('RGB')
arr = np.array(img)
print(f"Max pixel: {arr.max()}")
print(f"Mean pixel: {arr.mean()}")
