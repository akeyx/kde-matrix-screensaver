import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    width: parent ? parent.width : 1920
    height: parent ? parent.height : 1080
    color: activeConfig.backgroundColor || "#000000"

    // Recording control properties
    property bool recordingEnabled: false
    property int frameCounter: 0

    // Stateless global simulation time (in seconds)
    property double simTime: 0.0
    property double lastTime: Date.now()

    // Plasma 6 injects the configuration into this property on the root item
    property var configuration: null
    property var testProxyConfig: null
    readonly property var defaultConfig: ({
        version: "classic",
        font: "matrixcode",
        effect: "palette",
        scalingMode: 1,
        characterSize: 24,
        numColumns: 80,
        animationSpeed: 1.0,
        fallSpeed: 0.3,
        cycleSpeed: 0.03,
        raindropLength: 0.75,
        slant: 0.0,
        bloomSize: 0.4,
        bloomStrength: 0.7,
        ditherMagnitude: 0.05,
        resolution: 0.75,
        cursorColor: "#c1ff75",
        backgroundColor: "#000000",
        glintColor: "#ffffff",
        volumetric: false,
        glyphFlip: false,
        glyphRotation: 0,
        skipIntro: true,
        suppressWarnings: true,
        camera: false,
        stripeColors: "",
        palette: ""
    })

    readonly property var activeConfig: {
        if (testProxyConfig) return testProxyConfig;
        // Direct property injection on root item (Plasma 6 screenlockers)
        if (configuration && configuration.characterSize !== undefined) return configuration;
        // Direct context property (sometimes used in other Plasma shells)
        if (typeof configuration !== 'undefined' && configuration && configuration.characterSize !== undefined) return configuration;
        // Standard global wallpaper object
        if (typeof wallpaper !== 'undefined' && wallpaper) {
            if (wallpaper.configuration) return wallpaper.configuration;
            if (wallpaper.characterSize !== undefined) return wallpaper;
        }
        return defaultConfig;
    }

    FontLoader {
        id: matrixFont
        source: "../matrix/assets/Matrix-Code.ttf"
    }

    // Grid size parameters
    readonly property int columnsCount: {
        if (activeConfig.scalingMode === 1) {
            // Fixed Character Size (Auto-fill columns based on screen width)
            return Math.max(1, Math.floor(width / (activeConfig.characterSize !== undefined ? activeConfig.characterSize : 24)))
        } else {
            // Fixed Number of Columns
            return activeConfig.numColumns !== undefined ? activeConfig.numColumns : 80
        }
    }
    readonly property double colWidth: width / columnsCount
    readonly property double cellHeight: colWidth

    // Cache list of columns for ultra-fast access in JavaScript (0% CPU)
    property var colsArray: []
    
    // Staggered ticks for text cycling to ensure cells change independently without evaluating 2400 bindings every frame
    property double cycleSpeed: activeConfig.cycleSpeed !== undefined ? activeConfig.cycleSpeed : 0.03
    property int cycleTick1: Math.floor((root.simTime + 0.00) * 60.0 * cycleSpeed)
    property int cycleTick2: Math.floor((root.simTime + 10.11) * 60.0 * cycleSpeed)
    property int cycleTick3: Math.floor((root.simTime + 20.22) * 60.0 * cycleSpeed)
    property int cycleTick4: Math.floor((root.simTime + 30.33) * 60.0 * cycleSpeed)
    property int cycleTick5: Math.floor((root.simTime + 40.44) * 60.0 * cycleSpeed)
    
    // Cached color properties to prevent per-cell QVariant lookups and enable native HSLA bindings
    // Force WebGL exact hue (108 degrees / 0.3) to perfectly match the original matrix green tint
    property real baseHue: 0.3
    property real baseSat: 1.0
    
    property color activeCursorColor: activeConfig.cursorColor || "#2de500"
    property real activeHue: activeCursorColor.hslHue
    property real activeSat: activeCursorColor.hslSaturation

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
            angle: (activeConfig.slant !== undefined ? activeConfig.slant : 0.0) * 180 / Math.PI
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
                readonly property double zDepth: (activeConfig.volumetric || false) ? (randomFloat(index + 0.2, 0.0) * 0.75 + 0.25) : 1.0

                // Column time is driven purely by C++ bindings, completely eliminating JS loop overhead
                property double columnTime: columnTimeOffset + root.simTime * (activeConfig.fallSpeed !== undefined ? activeConfig.fallSpeed : 0.3) * columnSpeedOffset

                readonly property int trailLength: Math.ceil(100 * (activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75))
                readonly property int maxVisibleRows: Math.ceil(root.height / root.colWidth) + 3
                readonly property double slant: activeConfig.slant !== undefined ? activeConfig.slant : 0.0
                readonly property double rainTimeStep: (root.cellHeight / Math.max(1, root.height)) * 0.5 / (activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75)

                // 2. The Trail (fixed grid evaluating the GLSL brightness function)
                Repeater {
                    id: trailRepeater
                    model: columnItem.maxVisibleRows
                    delegate: Item {
                        width: colWidth
                        height: cellHeight
                        y: index * cellHeight
                        
                        readonly property double raindropLength: activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75
                        readonly property double rawRainTime: ((1.0 - ((index * root.cellHeight) / Math.max(1, root.height))) * 0.5 + columnItem.columnTime) / (activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75)
                        
                        readonly property double rawBrightness: {
                            var w = (activeConfig.loops || false || columnItem.slant === 0.0) ? rawRainTime : (rawRainTime + Math.sin(rawRainTime * Math.PI) * columnItem.slant);
                            return 1.0 - (w - Math.floor(w));
                        }
                        
                        readonly property double adjustedBrightness: Math.max(0.0, rawBrightness * 1.1 - 0.5)
                        
                        // Hide off-screen or totally dark cells to save render time
                        visible: adjustedBrightness > 0.01

                        // Mathematically isolate the exact single leading cursor cell
                        readonly property bool isCursor: {
                            var step = (activeConfig.loops || false || columnItem.slant === 0.0) ? columnItem.rainTimeStep : (columnItem.rainTimeStep * Math.max(0.1, 1.0 + Math.cos(rawRainTime * Math.PI) * columnItem.slant * Math.PI));
                            return rawBrightness > (1.0 - step);
                        }

                        readonly property int rValue: {
                            var x = Math.sin(columnItem.colIndex * 12.9898 + (index * 13) * 78.233) * 43758.5453;
                            return Math.floor((x - Math.floor(x)) * 5);
                        }

                        readonly property int myCycleTick: {
                            if (rValue === 0) return root.cycleTick1;
                            if (rValue === 1) return root.cycleTick2;
                            if (rValue === 2) return root.cycleTick3;
                            if (rValue === 3) return root.cycleTick4;
                            return root.cycleTick5;
                        }

                        readonly property double textSeed2Base: {
                            var x = Math.sin(columnItem.colIndex * 12.9898 + (index + 1000) * 78.233) * 43758.5453;
                            return index + Math.floor(x - Math.floor(x));
                        }

                        Text {
                            anchors.fill: parent
                            text: {
                                var s2 = textSeed2Base + myCycleTick;
                                var x = Math.sin(columnItem.colIndex * 12.9898 + s2 * 78.233) * 43758.5453;
                                return charsList[Math.floor((x - Math.floor(x)) * charsList.length)];
                            }
                            // The mathematically isolated leading cursor gets the exact WebGL yellow-green "electric" hue (0.242)!
                            // When this blooms, it spreads a slightly yellow-green tint around the brightest parts of the trail.
                            // The tail matches the WebGL palette mapping: pure matrix green (0.3 / 108 deg).
                            color: isCursor ? (activeConfig.glintColor || "#e7fecc") : Qt.hsla(root.activeHue, root.activeSat, Math.min(0.8, adjustedBrightness), 1.0)
                            
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
                                    angle: activeConfig.glyphRotation !== undefined ? activeConfig.glyphRotation : 0
                                },
                                Scale {
                                    origin.x: parent.width / 2
                                    origin.y: parent.height / 2
                                    xScale: activeConfig.glyphFlip ? -1 : 1
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
        visible: false
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

    // Define properties updated explicitly every frame to bypass QML var binding bugs
    property real currentBloomSize: 0.4
    property real currentBloomStrength: 0.7
    property real bloomScale: 1.0
    property real bloomDownsample: 4.0
    property real bloomRadiusMultiplier: 1.0

    // 3 & 4. Downsampled Base for all Bloom Passes
    // Using a single ShaderEffectSource guarantees Qt6 RHI populates the texture correctly
    ShaderEffectSource {
        id: bloomSource
        sourceItem: squaredSource
        hideSource: false
        live: true
        textureSize: Qt.size(Math.max(1, Math.ceil(softBaseSource.width / root.bloomDownsample)), Math.max(1, Math.ceil(softBaseSource.height / root.bloomDownsample)))
        visible: false
    }

    FastBlur {
        id: massiveBloom
        anchors.fill: softBaseSource
        source: bloomSource
        radius: 32 * root.bloomRadiusMultiplier
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

    FastBlur {
        id: outerBloom
        anchors.fill: softBaseSource
        source: bloomSource
        radius: 64 * root.bloomRadiusMultiplier
        visible: false
    }

    FastBlur {
        id: midBloom
        anchors.fill: softBaseSource
        source: bloomSource
        radius: 24 * root.bloomRadiusMultiplier
        visible: false
    }

    FastBlur {
        id: innerBloom
        anchors.fill: softBaseSource
        source: bloomSource
        radius: 8 * root.bloomRadiusMultiplier
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
    
    // Apply bloomStrength by multiplying the bloom RGB channels
    // Apply bloomStrength directly by darkening the RGB channels via BrightnessContrast.
    // This is 100% robust in Qt6 RHI (unlike blending a hidden raw Rectangle).
    BrightnessContrast {
        id: dimmedBloom
        anchors.fill: softBaseSource
        source: combinedBloom
        brightness: root.currentBloomStrength - 1.0
        visible: false
    }

    ShaderEffectSource {
        id: dimmedBloomSource
        sourceItem: dimmedBloom
        hideSource: true
        anchors.fill: dimmedBloom
        visible: false
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

    // Simulation driver synchronized with scene graph vsync
    property real animationDriver: 0.0
    NumberAnimation on animationDriver {
        from: 0.0
        to: 1.0
        duration: 1000
        loops: Animation.Infinite
        running: true
    }

    onAnimationDriverChanged: {
        // Explicitly sync config properties to bypass var binding limitations
        root.currentBloomSize = activeConfig.bloomSize !== undefined ? activeConfig.bloomSize : 0.4;
        root.currentBloomStrength = activeConfig.bloomStrength !== undefined ? activeConfig.bloomStrength : 0.7;
        root.bloomScale = Math.max(0.01, root.currentBloomSize) / 0.4;
        root.bloomDownsample = root.bloomScale > 1.0 ? 4.0 * root.bloomScale : 4.0;
        root.bloomRadiusMultiplier = root.bloomScale > 1.0 ? 1.0 : root.bloomScale;

        if (columnsRepeater.count > 0 && columnsRepeater.count !== root.colsArray.length) {
            var temp = [];
            for (var i = 0; i < columnsRepeater.count; i++) {
                var item = columnsRepeater.itemAt(i);
                if (item) temp.push(item);
            }
            if (temp.length === columnsRepeater.count) {
                root.colsArray = temp;
            }
        }

        if (colsArray.length === 0) return;

        var now = Date.now();
        // Fallback for first frame
        if (root.lastTime === 0 || !root.lastTime) root.lastTime = now;
        var dt = (now - root.lastTime) / 1000.0;
        root.lastTime = now;
        
        // Cap delta time to prevent massive jumps if animation stops
        if (dt > 0.1) dt = 0.016;

        var timeStep = dt * (activeConfig.animationSpeed !== undefined ? activeConfig.animationSpeed : 1.0);
        root.simTime += timeStep;
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


}
