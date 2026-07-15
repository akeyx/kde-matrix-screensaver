cd /home/a.key/projects/a.key/kde/kde-matrix-screensaver

export DISPLAY=:0

# 1. No Bloom
sed -i 's/bloomSizeParam: 1.0/bloomSizeParam: 0.0/; s/bloomStrengthParam: 1.0/bloomStrengthParam: 0.0/' generate_comparison.qml
qml-qt6 generate_comparison.qml
mv true_bloom_0.0.png true_bloom_0_fixed.png

# 2. Max Bloom
sed -i 's/bloomSizeParam: 0.0/bloomSizeParam: 1.0/; s/bloomStrengthParam: 0.0/bloomStrengthParam: 1.0/' generate_comparison.qml
qml-qt6 generate_comparison.qml
mv true_bloom_1.0.png true_bloom_1_fixed.png

mv true_bloom_*_fixed.png /home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/
