import re

with open('main.qml', 'r') as f:
    content = f.read()

# Replace updateGlyphs and init part
new_update_glyphs = """
        property var textArray: []

        function initGlyphs() {
            var arr = new Array(screenRows * (numColumns + 1));
            for (var i = 0; i < screenRows; i++) {
                for (var j = 0; j < numColumns; j++) {
                    arr[i * (numColumns + 1) + j] = glyphSet.charAt(Math.floor(Math.random() * glyphSet.length));
                }
                arr[i * (numColumns + 1) + numColumns] = "\\n";
            }
            textArray = arr;
            container.text = arr.join("");
        }

        function updateGlyphs() {
            if (textArray.length === 0) return;
            var arr = textArray;
            var changed = false;
            // Only update ~3% of characters per frame
            for (var i = 0; i < arr.length; i++) {
                if (arr[i] !== "\\n" && Math.random() < 0.03) {
                    arr[i] = glyphSet.charAt(Math.floor(Math.random() * glyphSet.length));
                    changed = true;
                }
            }
            if (changed) {
                container.text = arr.join("");
            }
        }
"""

content = re.sub(r'function updateGlyphs\(\) \{.*?\n        \}', new_update_glyphs.strip(), content, flags=re.DOTALL)
content = re.sub(r'Component\.onCompleted: \{\s*updateGlyphs\(\)\s*\}', 'Component.onCompleted: { initGlyphs() }', content, flags=re.DOTALL)
content = re.sub(r'onScreenRowsChanged: \{\s*updateGlyphs\(\)\s*\}', 'onScreenRowsChanged: { initGlyphs() }', content, flags=re.DOTALL)
content = re.sub(r'onNumColumnsChanged: \{\s*updateGlyphs\(\)\s*\}', 'onNumColumnsChanged: { initGlyphs() }', content, flags=re.DOTALL)

with open('main.qml', 'w') as f:
    f.write(content)
