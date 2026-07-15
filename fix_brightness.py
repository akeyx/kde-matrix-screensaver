import re

with open('contents/ui/rain.frag', 'r') as f:
    content = f.read()

# Replace pow logic
old_logic = "float visualBrightness = clamp(pow(adjustedBrightness, 0.6) * 1.5, 0.0, 1.0);"
new_logic = "float visualBrightness = clamp(adjustedBrightness * 1.7, 0.0, 1.0);"

if old_logic in content:
    content = content.replace(old_logic, new_logic)
else:
    print("Could not find old logic!")

with open('contents/ui/rain.frag', 'w') as f:
    f.write(content)
