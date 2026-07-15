from PIL import Image
import numpy as np

try:
    img = Image.open('bloomSource.png').convert('RGB')
    arr = np.array(img)
    print(f"Max pixel: {arr.max()}")
    print(f"Mean pixel: {arr.mean()}")
except Exception as e:
    print(e)
