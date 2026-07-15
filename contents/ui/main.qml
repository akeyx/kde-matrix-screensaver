import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Rectangle {
    id: root
    width: parent ? parent.width : 1920
    height: parent ? parent.height : 1080
    color: activeConfig.backgroundColor || "#000000"

    // Recording control properties
    property bool recordingEnabled: false
    property int frameCounter: 0

    // Plasma 6 injects the configuration into this property on the root item
    property var configuration: null
    property var testProxyConfig: null
    readonly property var defaultConfig: ({
        version: "classic",
        font: "matrixcode",
        effect: "palette",
        scalingMode: 1,
        characterSize: 40,
        numColumns: 80,
        animationSpeed: 1.0,
        fallSpeed: 0.3,
        cycleSpeed: 0.03,
        raindropLength: 0.75,
        slant: 0.0,
        bloomSize: 0.4,
        bloomStrength: 0.1,
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
            return Math.max(1, Math.floor(width / (activeConfig.characterSize !== undefined ? activeConfig.characterSize : 40)))
        } else {
            // Fixed Number of Columns
            return activeConfig.numColumns !== undefined ? activeConfig.numColumns : 80
        }
    }
    readonly property double colWidth: width / columnsCount
    readonly property double cellHeight: colWidth

    // Cache list of columns for ultra-fast access in JavaScript (0% CPU)
    property var colsArray: []
    
    // Global cycle speed for independent cell cycle updates
    property double cycleSpeed: activeConfig.cycleSpeed !== undefined ? activeConfig.cycleSpeed : 0.03
    
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
                        
                        // CPU bindings stripped; math moved to GPU ShaderEffect

                        readonly property double textSeed2Base: {
                            var x = Math.sin(columnItem.colIndex * 12.9898 + (index + 1000) * 78.233) * 43758.5453;
                            return index + (x - Math.floor(x));
                        }
                        
                        // Generate a unique starting phase offset between 0.0 and 1.0
                        readonly property double cycleOffset: textSeed2Base - Math.floor(textSeed2Base)
                        
                        // Decouple text evaluation from the 60fps simTime to save massive CPU
                        readonly property int myCycleTick: Math.floor((root.globalTextTimer * 60.0 * root.cycleSpeed) + cycleOffset)

                        Text {
                            anchors.fill: parent
                            text: {
                                var s2 = textSeed2Base + myCycleTick;
                                var x = Math.sin(columnItem.colIndex * 12.9898 + s2 * 78.233) * 43758.5453;
                                return charsList[Math.floor((x - Math.floor(x)) * charsList.length)];
                            }
                            // Pure white solid text; colored by ShaderEffect on GPU
                            color: "#ffffff"
                            
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

    ShaderEffect {
        id: rainColored
        anchors.fill: softBaseSource
        visible: false // Will be read by rainColoredSource
        property variant source: softBaseSource
        property real simTime: root.simTime
        property real fallSpeed: activeConfig.fallSpeed !== undefined ? activeConfig.fallSpeed : 0.3
        property real raindropLength: activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75
        property real slant: activeConfig.slant !== undefined ? activeConfig.slant : 0.0
        property real numColumns: root.columnsCount
        property real screenRows: root.height / root.cellHeight
        property real cellHeightRatio: root.cellHeight / Math.max(1, root.height)
        property int volumetric: (activeConfig.volumetric || false) ? 1 : 0
        property int loops: (activeConfig.loops || false) ? 1 : 0
        property color glintColor: activeConfig.glintColor || "#e7fecc"
        property color baseColor: Qt.hsla(root.activeHue, root.activeSat, 0.5, 1.0)
        fragmentShader: "rain.frag.qsb"
    }

    ShaderEffectSource {
        id: rainColoredSource
        sourceItem: rainColored
        hideSource: true
        anchors.fill: rainColored
        visible: false
    }

    // 2. High-Pass Filter: Multiply the screen by itself once (squared curve) 
    // This perfectly isolates the pure white cursors and extreme neon green spots, 
    // suppressing the dark green trails so they don't emit muddy fog.
    Item {
        id: squaredContainer
        anchors.fill: rainColoredSource
        Blend {
            anchors.fill: parent
            source: rainColoredSource
            foregroundSource: rainColoredSource
            mode: "multiply"
        }
    }

    ShaderEffectSource {
        id: squaredSource
        sourceItem: squaredContainer
        hideSource: true
        anchors.fill: squaredContainer
    }

    // Define properties updated explicitly every frame to bypass QML var binding bugs
    property real currentBloomSize: 0.4
    property real currentBloomStrength: 0.1
    property real bloomScale: 1.0
    property real bloomDownsample: 1.0
    property real bloomRadiusMultiplier: 1.0

    // MultiEffect must not be visible: false, otherwise it is optimized out in Qt6.
    // We put it in an Item and hide it with ShaderEffectSource.
    Item {
        id: intenseBloomContainer
        anchors.fill: softBaseSource
        MultiEffect {
            id: intenseBloom
            anchors.fill: parent
            source: squaredSource
            blurEnabled: true
            blurMax: 64 * root.bloomRadiusMultiplier
            blur: 1.0
            shadowEnabled: true
            shadowBlur: 1.0
            shadowColor: activeConfig.glintColor || "#e7fecc"
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0
        }
    }

    ShaderEffectSource {
        id: intenseBloomSource
        sourceItem: intenseBloomContainer
        hideSource: true
        anchors.fill: intenseBloomContainer
    }

    // Capture the final bloom with the requested opacity applied during rendering!
    Item {
        id: dimmedBloomContainer
        anchors.fill: softBaseSource
        ShaderEffectSource {
            anchors.fill: parent
            sourceItem: intenseBloomContainer
            hideSource: true
            opacity: root.currentBloomStrength
        }
    }

    ShaderEffectSource {
        id: dimmedBloomSrc
        sourceItem: dimmedBloomContainer
        hideSource: true
        anchors.fill: dimmedBloomContainer
    }

    // Final composition
    Blend {
        anchors.fill: rainColoredSource
        source: rainColoredSource
        foregroundSource: dimmedBloomSrc
        mode: "screen" 
    }

    // Character set
    readonly property var charsList: ["モ", "エ", "ヤ", "キ", "オ", "カ", "7", "ケ", "サ", "ス", "z", "1", "5", "2", "ヨ", "タ", "ワ", "4", "ネ", "ヌ", "ナ", "9", "8", "ヒ", "0", "ホ", "ア", "3", "ウ", "セ", "ミ", "ラ", "リ", "ツ", "テ", "ニ", "ハ", "ソ", "コ", "シ", "マ", "ム", "メ"]

    // Pure native continuous time driver (perfectly vsync locked, 0 timer jitter)
    property real internalSimTime: 0.0
    NumberAnimation on internalSimTime {
        from: 0.0
        to: 1000000.0
        duration: 1000000000
        loops: Animation.Infinite
        running: true
    }

    // Apply speed scaling declaratively
    property real simTime: internalSimTime * (activeConfig.animationSpeed !== undefined ? activeConfig.animationSpeed : 1.0)

    // Separate low-frequency timer for text symbol updates (drops CPU from 170% to 15%)
    property real globalTextTimer: 0.0
    Timer {
        interval: 50 // 20 updates per second is plenty for discrete character flips
        running: true
        repeat: true
        onTriggered: {
            root.globalTextTimer += 0.05 * (activeConfig.animationSpeed !== undefined ? activeConfig.animationSpeed : 1.0)
        }
    }

    // Trigger config updates periodically instead of every frame
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            root.currentBloomSize = activeConfig.bloomSize !== undefined ? activeConfig.bloomSize : 0.4;
            root.currentBloomStrength = activeConfig.bloomStrength !== undefined ? activeConfig.bloomStrength : 0.1;
            root.bloomScale = Math.max(0.01, root.currentBloomSize) / 0.4;
            root.bloomDownsample = 4.0;
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


}
