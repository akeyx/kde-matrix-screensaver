import numpy as np
import matplotlib.pyplot as plt

raw = np.linspace(0, 1, 100)
adjusted = np.maximum(0.0, raw * 1.1 - 0.5)
visual = np.clip(adjusted * 1.8, 0.0, 1.0) # linear boost
visual_pow = np.clip(np.power(adjusted, 0.6) * 1.5, 0.0, 1.0)

for r, a, v, vp in zip(raw, adjusted, visual, visual_pow):
    if r > 0.45:
        print(f"raw: {r:.2f} -> adj: {a:.2f} -> vis: {v:.2f} -> vpow: {vp:.2f}")
