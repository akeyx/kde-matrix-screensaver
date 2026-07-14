import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: wallpaper.configuration.backgroundColor || "#000000"

    // Recording control properties
    property bool recordingEnabled: false
    property int frameCounter: 0

    // Stateless global simulation time (in seconds)
    property double simTime: 0.0
    property double lastTime: Date.now()

    // Default wallpaper config for standalone testing.
    // When running inside Plasma, the engine injects its own "wallpaper"
    // context property which overrides this one automatically.
    property QtObject wallpaper: QtObject {
        readonly property QtObject configuration: QtObject {
            property string version: "classic"
            property string font: "matrixcode"
            property string effect: "palette"
            property int numColumns: 80
            property double animationSpeed: 1.0
            property double fallSpeed: 0.3
            property double cycleSpeed: 0.03
            property double raindropLength: 0.75
            property double slant: 0.0
            property double bloomSize: 0.4
            property double bloomStrength: 0.7
            property double ditherMagnitude: 0.05
            property double resolution: 0.75
            property color cursorColor: "#c1ff75"
            property color backgroundColor: "#000000"
            property color glintColor: "#ffffff"
            property bool volumetric: false
            property bool glyphFlip: false
            property int glyphRotation: 0
            property bool skipIntro: true
            property bool suppressWarnings: true
            property bool camera: false
            property string stripeColors: ""
            property string palette: ""
        }
    }

    FontLoader {
        id: matrixFont
        source: "../matrix/assets/Matrix-Code.ttf"
    }

    // Grid size parameters
    readonly property int columnsCount: {
        if (wallpaper.configuration.scalingMode === 1) {
            // Fixed Character Size (Auto-fill columns based on screen width)
            return Math.max(1, Math.floor(width / (wallpaper.configuration.characterSize || 24)))
        } else {
            // Fixed Number of Columns
            return wallpaper.configuration.numColumns || 80
        }
    }
    readonly property double colWidth: width / columnsCount
    readonly property double cellHeight: colWidth

    // Cache list of columns for ultra-fast access in JavaScript (0% CPU)
    property var colsArray: []
    
    // Staggered ticks for text cycling to ensure cells change independently without evaluating 2400 bindings every frame
    property double cycleSpeed: wallpaper.configuration.cycleSpeed || 0.03
    property int cycleTick1: Math.floor((root.simTime + 0.00) * 60.0 * cycleSpeed)
    property int cycleTick2: Math.floor((root.simTime + 10.11) * 60.0 * cycleSpeed)
    property int cycleTick3: Math.floor((root.simTime + 20.22) * 60.0 * cycleSpeed)
    property int cycleTick4: Math.floor((root.simTime + 30.33) * 60.0 * cycleSpeed)
    property int cycleTick5: Math.floor((root.simTime + 40.44) * 60.0 * cycleSpeed)
    
    // Cached color properties to prevent per-cell QVariant lookups and enable native HSLA bindings
    // Force WebGL exact hue (108 degrees / 0.3) to perfectly match the original matrix green tint
    property real baseHue: 0.3
    property real baseSat: 1.0
    
    // Pre-calculated palette for massive performance gain
    property var paletteCache: []
    
    property color activeCursorColor: wallpaper.configuration.cursorColor || "#2de500"
    onActiveCursorColorChanged: updatePalette()
    
    function updatePalette() {
        var cache = []
        for (var i = 0; i <= 100; i++) {
            cache.push(getTrailColor(activeCursorColor, i / 100.0))
        }
        paletteCache = cache
    }
    
    Component.onCompleted: {
        updatePalette()
    }

    // Stateless deterministic random float generator matching GLSL fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453)
    function randomFloat(x, y) {
        var a = 12.9898, b = 78.233, c = 43758.5453;
        var dt = x * a + y * b;
        var sn = dt % Math.PI;
        var val = Math.sin(sn) * c;
        var res = val - Math.floor(val);
        if (isNaN(res) || res < 0) return 0.0;
        if (res >= 1.0) return 0.999;
        return res;
    }

    // Natural falling variation wobble matching GLSL wobble(x)
    function wobble(x) {
        return x + 0.3 * Math.sin(1.41421356 * x) + 0.2 * Math.sin(2.23606797 * x);
    }

    // Container for GPU rendering elements
    Item {
        id: container
        anchors.fill: parent

        // Apply Slant natively via QML Rotation transform (runs on GPU!)
        transform: Rotation {
            origin.x: container.width / 2
            origin.y: container.height / 2
            angle: (wallpaper.configuration.slant || 0.0) * 180 / Math.PI
        }


        Repeater {
            id: columnsRepeater
            model: columnsCount
            delegate: Item {
                id: columnItem
                x: index * colWidth
                width: colWidth
                height: container.height

                // Column properties (stateless math constants)
                readonly property int colIndex: index
                readonly property double columnTimeOffset: randomFloat(index, 0.0) * 1000.0
                readonly property double columnSpeedOffset: randomFloat(index + 0.1, 0.0) * 0.5 + 0.5
                readonly property double zDepth: (wallpaper.configuration.volumetric || false) ? (randomFloat(index + 0.2, 0.0) * 0.75 + 0.25) : 1.0

                // Column time is driven purely by C++ bindings, completely eliminating JS loop overhead
                property double columnTime: columnTimeOffset + root.simTime * (wallpaper.configuration.fallSpeed || 0.3) * columnSpeedOffset

                readonly property int trailLength: Math.ceil(100 * (wallpaper.configuration.raindropLength || 0.75))
                readonly property int maxVisibleRows: Math.ceil(root.height / root.colWidth) + 3

                // 2. The Trail (fixed grid evaluating the GLSL brightness function)
                Repeater {
                    id: trailRepeater
                    model: columnItem.maxVisibleRows
                    delegate: Item {
                        width: colWidth
                        height: cellHeight
                        y: index * cellHeight
                        
                        readonly property double raindropLength: wallpaper.configuration.raindropLength || 0.75
                        // Apply standard WebGL cyclic gradient
                        readonly property double rawRainTime: ((columnItem.maxVisibleRows - index) * 0.01 + columnItem.columnTime) / wallpaper.configuration.raindropLength
                        readonly property double wobbledRainTime: wallpaper.configuration.loops ? rawRainTime : root.wobble(rawRainTime)
                        
                        // In WebGL, the base brightness is fract(wobbledRainTime).
                        readonly property double rawBrightness: 1.0 - (wobbledRainTime - Math.floor(wobbledRainTime))
                        
                        // WebGL applies baseContrast (1.1) and baseBrightness (-0.5). 
                        // This math truncates the tails, making the screen sparse and pitch black in empty areas.
                        readonly property double adjustedBrightness: Math.max(0.0, rawBrightness * 1.1 - 0.5)
                        
                        // Hide off-screen or totally dark cells to save render time
                        visible: adjustedBrightness > 0.01

                        // Mathematically isolate the exact single leading cursor cell by comparing with the cell BELOW, exactly matching WebGL
                        readonly property double nextRainTime: ((columnItem.maxVisibleRows - (index + 1)) * 0.01 + columnItem.columnTime) / raindropLength
                        readonly property double nextWobbled: wallpaper.configuration.loops ? nextRainTime : root.wobble(nextRainTime)
                        readonly property double nextBrightness: 1.0 - (nextWobbled - Math.floor(nextWobbled))
                        readonly property bool isCursor: adjustedBrightness > nextBrightness

                        readonly property int myCycleTick: {
                            var r = Math.floor(randomFloat(columnItem.colIndex, index * 13) * 5);
                            if (r === 0) return root.cycleTick1;
                            if (r === 1) return root.cycleTick2;
                            if (r === 2) return root.cycleTick3;
                            if (r === 3) return root.cycleTick4;
                            return root.cycleTick5;
                        }

                        Text {
                            anchors.fill: parent
                            text: parent.visible ? charsList[Math.floor(randomFloat(columnItem.colIndex, index + Math.floor(randomFloat(columnItem.colIndex, index + 1000) + myCycleTick)) * charsList.length)] : ""
                            // The mathematically isolated leading cursor gets the exact WebGL yellow-green "electric" hue (0.242)!
                            // When this blooms, it spreads a slightly yellow-green tint around the brightest parts of the trail.
                            // The tail matches the WebGL palette mapping: pure matrix green (0.3 / 108 deg).
                            color: isCursor ? (wallpaper.configuration.glintColor || "#e7fecc") : (paletteCache[Math.floor(adjustedBrightness * 100)] || Qt.hsla(root.baseHue, root.baseSat, Math.min(0.8, adjustedBrightness), 1.0))
                            
                            // Fade out opacity smoothly using native C++ math
                            opacity: isCursor ? 1.0 : adjustedBrightness * columnItem.zDepth
                            
                            font.family: matrixFont.name
                            font.pixelSize: Math.ceil(parent.width * 1.15 * columnItem.zDepth)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            transform: [
                                Rotation {
                                    origin.x: parent.width / 2
                                    origin.y: parent.height / 2
                                    angle: wallpaper.configuration.glyphRotation || 0
                                },
                                Scale {
                                    origin.x: parent.width / 2
                                    origin.y: parent.height / 2
                                    xScale: wallpaper.configuration.glyphFlip ? -1 : 1
                                }
                            ]
                        }
                    }
                }
            }
        }
    }

    ShaderEffectSource {
        id: containerSource
        sourceItem: container
        hideSource: true
        anchors.fill: container
    }

    // Soften the razor-sharp vector text to match WebGL's raster font texture
    FastBlur {
        id: softBase
        anchors.fill: containerSource
        source: containerSource
        radius: 3
        transparentBorder: true
        visible: false
    }

    ShaderEffectSource {
        id: softBaseSource
        sourceItem: softBase
        hideSource: true
        anchors.fill: softBase
    }

    // 2. High-Pass Filter: Multiply the screen by itself once (squared curve) 
    // This perfectly isolates the pure white cursors and extreme neon green spots, 
    // suppressing the dark green trails so they don't emit muddy fog.
    Blend {
        id: squaredSource
        anchors.fill: softBaseSource
        source: softBaseSource
        foregroundSource: softBaseSource
        mode: "multiply"
        visible: false
    }

    // 3. Downsampled Massive Bloom (fed ONLY by the high-pass mask)
    ShaderEffectSource {
        id: downsampledHighPass
        sourceItem: squaredSource
        hideSource: false
        textureSize: Qt.size(Math.ceil(softBaseSource.width / 4), Math.ceil(softBaseSource.height / 4))
        visible: false
    }

    FastBlur {
        id: massiveBloom
        anchors.fill: softBaseSource
        source: downsampledHighPass
        radius: 32 // Effective radius 128
        visible: false
    }

    // Double the massive bloom intensity to make the cursors violently glow
    Blend {
        id: intenseMassiveBloom
        anchors.fill: softBaseSource
        source: massiveBloom
        foregroundSource: massiveBloom
        mode: "addition"
        visible: false
    }

    // 4. Standard Gaussian Bloom Pyramid (for the soft wide halos on the regular trails)
    // Downsample the high-pass base to 40% to exactly match WebGL's "bloomSize: 0.4"
    ShaderEffectSource {
        id: downsampledBase
        sourceItem: squaredSource // Feed from the squared curve so bright spots bloom much more than fading trails
        hideSource: false
        textureSize: Qt.size(Math.max(1, Math.ceil(softBaseSource.width * Math.max(0.01, wallpaper.configuration.bloomSize !== undefined ? wallpaper.configuration.bloomSize : 0.4))), Math.max(1, Math.ceil(softBaseSource.height * Math.max(0.01, wallpaper.configuration.bloomSize !== undefined ? wallpaper.configuration.bloomSize : 0.4))))
        visible: false
    }

    FastBlur {
        id: outerBloom
        anchors.fill: softBaseSource
        source: downsampledBase
        radius: 64 // Effective 160
        visible: false
    }

    FastBlur {
        id: midBloom
        anchors.fill: softBaseSource
        source: downsampledBase
        radius: 24 // Effective 60
        visible: false
    }

    FastBlur {
        id: innerBloom
        anchors.fill: softBaseSource
        source: downsampledBase
        radius: 8 // Effective 20
        visible: false
    }

    Blend {
        id: combinedOuterMid
        anchors.fill: softBaseSource
        source: outerBloom
        foregroundSource: midBloom
        mode: "addition" // Sum the blurs for much higher energy on the bright spots
        visible: false
    }

    Blend {
        id: standardTrailBloom
        anchors.fill: softBaseSource
        source: combinedOuterMid
        foregroundSource: innerBloom
        mode: "addition"
        visible: false
    }

    // Double the intensity of the standard background trail bloom
    Blend {
        id: intenseTrailBloom
        anchors.fill: softBaseSource
        source: standardTrailBloom
        foregroundSource: standardTrailBloom
        mode: "addition"
        visible: false
    }

    // 5. Combine the massive bright spot bloom with the standard wide trail bloom
    Blend {
        id: combinedBloom
        anchors.fill: softBaseSource
        source: intenseMassiveBloom
        foregroundSource: intenseTrailBloom
        mode: "screen"
        visible: false
    }
    
    ShaderEffectSource {
        id: combinedBloomSource
        sourceItem: combinedBloom
        hideSource: true
        anchors.fill: combinedBloom
    }

    // Apply bloomStrength by masking the alpha of the combined bloom
    Rectangle {
        id: bloomStrengthMask
        anchors.fill: softBaseSource
        color: Qt.rgba(0, 0, 0, wallpaper.configuration.bloomStrength || 0.7)
        visible: false
    }

    OpacityMask {
        id: dimmedBloom
        anchors.fill: softBaseSource
        source: combinedBloomSource
        maskSource: bloomStrengthMask
        visible: false
    }

    ShaderEffectSource {
        id: dimmedBloomSource
        sourceItem: dimmedBloom
        hideSource: true
        anchors.fill: dimmedBloom
    }

    // Final composition: Base + Dimmed Bloom
    Blend {
        anchors.fill: softBaseSource
        source: softBaseSource
        foregroundSource: dimmedBloomSource
        mode: "screen" 
    }

    // Character set
    readonly property var charsList: ["モ", "エ", "ヤ", "キ", "オ", "カ", "7", "ケ", "サ", "ス", "z", "1", "5", "2", "ヨ", "タ", "ワ", "4", "ネ", "ヌ", "ナ", "9", "8", "ヒ", "0", "ホ", "ア", "3", "ウ", "セ", "ミ", "ラ", "リ", "ツ", "テ", "ニ", "ハ", "ソ", "コ", "シ", "マ", "ム", "メ"]

    function hslToRgb(h, s, l) {
        var r, g, b;
        if (s === 0) {
            r = g = b = l;
        } else {
            var hue2rgb = function(p, q, t) {
                if (t < 0) t += 1;
                if (t > 1) t -= 1;
                if (t < 1/6) return p + (q - p) * 6 * t;
                if (t < 1/2) return q;
                if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
                return p;
            };
            var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
            var p = 2 * l - q;
            r = hue2rgb(p, q, h + 1/3);
            g = hue2rgb(p, q, h);
            b = hue2rgb(p, q, h - 1/3);
        }
        return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
    }

    function getTrailColor(c, brightness) {
        var r = c.r;
        var g = c.g;
        var b_c = c.b;
        var max = Math.max(r, g, b_c), min = Math.min(r, g, b_c);
        var h, s, l = (max + min) / 2;

        if (max === min) {
            h = s = 0;
        } else {
            var d = max - min;
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
            switch (max) {
                case r: h = (g - b_c) / d + (g < b_c ? 6 : 0); break;
                case g: h = (b_c - r) / d + 2; break;
                case b_c: h = (r - g) / d + 4; break;
            }
            h /= 6;
        }

        // Replicate WebGL's palette mapping: brightness dictates the color's Lightness (L)
        // A brightness of 1.0 is neon green (L=0.45). Anything below 0.4 is pure black.
        var trailL = Math.max(0.0, (brightness - 0.4) / 0.6 * 0.45);
        var trailS = Math.max(s, 0.85);

        var rgb = hslToRgb(h, trailS, trailL);
        return Qt.rgba(rgb[0]/255, rgb[1]/255, rgb[2]/255, 1.0);
    }

    // Startup timer to populate colsArray
    Timer {
        id: initTimer
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            var temp = [];
            for (var i = 0; i < columnsCount; i++) {
                temp.push(columnsRepeater.itemAt(i));
            }
            root.colsArray = temp;
        }
    }

    // Simulation Timer running at 60 FPS
    Timer {
        id: simulationTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            if (colsArray.length === 0) return;

            var now = Date.now();
            // Fallback for first frame
            if (root.lastTime === 0 || !root.lastTime) root.lastTime = now;
            var dt = (now - root.lastTime) / 1000.0;
            root.lastTime = now;
            
            // Cap delta time to prevent massive jumps if animation stops
            if (dt > 0.1) dt = 0.016;

            var timeStep = dt * (wallpaper.configuration.animationSpeed || 1.0);
            root.simTime += timeStep;

            // Simulation logic is entirely handled by QML property bindings now!
            // No massive 3200-iteration JS loops required here.
        }
    }

    // High performance sequential frame exporter for verification
    Timer {
        id: recordTimer
        interval: 100 // 10 FPS
        running: root.recordingEnabled && root.frameCounter < 100
        repeat: true
        onTriggered: {
            var currentFrame = root.frameCounter;
            root.frameCounter++;
            root.grabToImage(function(result) {
                var padStr = "" + currentFrame;
                while (padStr.length < 4) padStr = "0" + padStr;
                result.saveToFile("/home/a.key/.gemini/antigravity-cli/brain/a7c0cf4d-d517-4eaf-a857-64318c074c1d/scratch/frame_" + padStr + ".png");
            });
        }
    }

    Connections {
        target: wallpaper.configuration
        // declarative bindings automatically handle changes
    }
}
