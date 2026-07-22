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
        trailBrightness: 1.0,
        glintIntensity: 0.35,
        cursorIntensity: 0.5,
        raindropLength: 0.75,
        slant: 0.0,
        bloomSize: 0.4,
        bloomStrength: 0.7,
        ditherMagnitude: 0.05,
        resolution: 0.75,
        cursorColor: "#c1ff75",
        backgroundColor: "#000000",
        glintColor: "#c1ff75",

        skipIntro: true,
        suppressWarnings: true,
        camera: false,
        stripeColors: "",
        palette: ""
    })

    property var activeConfig: root.testProxyConfig ? root.testProxyConfig : 
                               (root.configuration && root.configuration.characterSize !== undefined ? root.configuration : 
                               (root.wallpaper && root.wallpaper.configuration ? root.wallpaper.configuration : 
                               (root.wallpaper && root.wallpaper.characterSize !== undefined ? root.wallpaper : root.defaultConfig)))

    FontLoader {
        id: matrixFont
        source: "../fonts/Matrix-Code.ttf"
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
                readonly property double zDepth: 1.0

                // Column time is driven purely by C++ bindings, completely eliminating JS loop overhead
                property double columnTime: columnTimeOffset + root.simTime * (activeConfig.fallSpeed !== undefined ? activeConfig.fallSpeed : 0.3) * columnSpeedOffset

                readonly property int trailLength: Math.ceil(100 * (activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75))
                readonly property int maxVisibleRows: Math.ceil(root.height / root.colWidth) + 3
                readonly property double slant: activeConfig.slant !== undefined ? activeConfig.slant : 0.0
                readonly property double rainTimeStep: (root.cellHeight / Math.max(1, root.height)) * 0.5 / (activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75)

                function randomizeRandomCell() {
                    let randomRow = Math.floor(Math.random() * trailRepeater.count);
                    let cell = trailRepeater.itemAt(randomRow);
                    if (cell) {
                        cell.randomizeChar();
                    }
                }

                // 2. The Trail (fixed grid evaluating the GLSL brightness function)
                Repeater {
                    id: trailRepeater
                    model: columnItem.maxVisibleRows
                    delegate: Item {
                        width: colWidth
                        height: cellHeight
                        y: index * cellHeight
                        
                        // CPU bindings stripped; math moved to GPU ShaderEffect

                        // Random starting char
                        Component.onCompleted: {
                            myText.text = charsList[Math.floor(Math.random() * charsList.length)]
                        }
                        
                        function randomizeChar() {
                            myText.text = charsList[Math.floor(Math.random() * charsList.length)]
                        }

                        Text {
                            id: myText
                            anchors.fill: parent
                            text: " "
                            // Pure white solid text; colored by ShaderEffect on GPU
                            color: "#ffffff"
                            
                            font.family: matrixFont.name
                            font.pixelSize: Math.ceil(parent.width * 1.15 * columnItem.zDepth)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter


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
        smooth: true
        visible: false
    }

    // Soften the razor-sharp vector text to match WebGL's raster font texture
    FastBlur {
        id: softBase
        anchors.fill: containerSource
        source: containerSource
        radius: 3 // Softness matching WebGL's phosphor raster font look
        transparentBorder: true
        visible: false
    }

    ShaderEffectSource {
        id: softBaseSource
        sourceItem: softBase
        hideSource: true
        anchors.fill: softBase
        smooth: true
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
        property real screenRows: root.height / Math.max(1, root.cellHeight)
        property real cellHeightRatio: root.cellHeight / Math.max(1, root.height)

        property real loops: (activeConfig.loops || false) ? 1.0 : 0.0
        property color glintColor: activeConfig.glintColor || "#c1ff75"
        property color baseColor: Qt.hsla(root.activeHue, root.activeSat, 0.5, 1.0)
        property real trailBrightness: activeConfig.trailBrightness !== undefined ? activeConfig.trailBrightness : 1.0
        property real glintIntensity: activeConfig.glintIntensity !== undefined ? activeConfig.glintIntensity : 1.0
        fragmentShader: "rain.frag.qsb"
    }

    ShaderEffectSource {
        id: rainColoredSource
        sourceItem: rainColored
        hideSource: true
        anchors.fill: rainColored
        smooth: true
        visible: false
    }

    // 2. High-Pass Filter: Multiply the screen by itself once (squared curve) 
    // This perfectly isolates the pure white cursors and extreme neon green spots, 
    // suppressing the dark green trails so they don't emit muddy fog.


    Item {
        id: squaredContainer
        anchors.fill: rainColoredSource
        ShaderEffect {
            anchors.fill: parent
            property variant sourceTex: rainColoredSource
            property real glintIntensity: activeConfig.glintIntensity !== undefined ? activeConfig.glintIntensity : 1.0
            property real cursorIntensity: activeConfig.cursorIntensity !== undefined ? activeConfig.cursorIntensity : 2.0
            fragmentShader: "squared.frag.qsb"
        }
    }

    ShaderEffectSource {
        id: squaredSource
        sourceItem: squaredContainer
        anchors.fill: squaredContainer
        smooth: true
        visible: false
    }

    // Define properties updated via declarative QML bindings
    property real currentBloomSize: activeConfig.bloomSize !== undefined ? activeConfig.bloomSize : 0.4
    property real currentBloomStrength: activeConfig.bloomStrength !== undefined ? activeConfig.bloomStrength : 0.7
    property real bloomScale: Math.max(0.01, currentBloomSize) / 0.4
    property real bloomDownsample: 4.0
    property real bloomRadiusMultiplier: bloomScale

    // Progressive downsample/blur pyramid levels
    // Level 0: bloomSize scale of screen (typically 0.4x)
    ShaderEffectSource {
        id: pyr0Downsample
        sourceItem: squaredContainer
        width: Math.max(1, root.width * root.currentBloomSize)
        height: Math.max(1, root.height * root.currentBloomSize)
        sourceRect: Qt.rect(0, 0, root.width, root.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr0Blur
        anchors.fill: pyr0Downsample
        source: pyr0Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr0Source
        sourceItem: pyr0Blur
        anchors.fill: pyr0Blur
        smooth: true
        visible: false
    }

    // Level 1: Half of Level 0
    ShaderEffectSource {
        id: pyr1Downsample
        sourceItem: pyr0Source
        width: Math.max(1, pyr0Downsample.width / 2)
        height: Math.max(1, pyr0Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr0Downsample.width, pyr0Downsample.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr1Blur
        anchors.fill: pyr1Downsample
        source: pyr1Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr1Source
        sourceItem: pyr1Blur
        anchors.fill: pyr1Blur
        smooth: true
        visible: false
    }

    // Level 2: Half of Level 1
    ShaderEffectSource {
        id: pyr2Downsample
        sourceItem: pyr1Source
        width: Math.max(1, pyr1Downsample.width / 2)
        height: Math.max(1, pyr1Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr1Downsample.width, pyr1Downsample.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr2Blur
        anchors.fill: pyr2Downsample
        source: pyr2Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr2Source
        sourceItem: pyr2Blur
        anchors.fill: pyr2Blur
        smooth: true
        visible: false
    }

    // Level 3: Half of Level 2
    ShaderEffectSource {
        id: pyr3Downsample
        sourceItem: pyr2Source
        width: Math.max(1, pyr2Downsample.width / 2)
        height: Math.max(1, pyr2Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr2Downsample.width, pyr2Downsample.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr3Blur
        anchors.fill: pyr3Downsample
        source: pyr3Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr3Source
        sourceItem: pyr3Blur
        anchors.fill: pyr3Blur
        smooth: true
        visible: false
    }

    // Level 4: Half of Level 3
    ShaderEffectSource {
        id: pyr4Downsample
        sourceItem: pyr3Source
        width: Math.max(1, pyr3Downsample.width / 2)
        height: Math.max(1, pyr3Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr3Downsample.width, pyr3Downsample.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr4Blur
        anchors.fill: pyr4Downsample
        source: pyr4Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr4Source
        sourceItem: pyr4Blur
        anchors.fill: pyr4Blur
        smooth: true
        visible: false
    }

    ShaderEffect {
        id: finalComposite
        anchors.fill: parent
        property variant primaryTex: rainColoredSource
        property variant pyr0Tex: pyr0Source
        property variant pyr1Tex: pyr1Source
        property variant pyr2Tex: pyr2Source
        property variant pyr3Tex: pyr3Source
        property variant pyr4Tex: pyr4Source
        property real bloomStrength: root.currentBloomStrength
        property color glintColor: activeConfig.glintColor || "#c1ff75"

        fragmentShader: "compose.frag.qsb"
    }

    // Character set
    readonly property var charsList: ["モ", "エ", "ヤ", "キ", "オ", "カ", "7", "ケ", "サ", "ス", "z", "1", "5", "2", "ヨ", "タ", "ワ", "4", "ネ", "ヌ", "ナ", "9", "8", "ヒ", "0", "ホ", "ア", "3", "ウ", "セ", "ミ", "ラ", "リ", "ツ", "テ", "ニ", "ハ", "ソ", "コ", "シ", "マ", "ム", "メ"]

    // Pure native continuous time driver (perfectly vsync locked, 0 timer jitter)
    property alias timeAnim: timeAnim
    property real internalSimTime: 0.0
    NumberAnimation {
        id: timeAnim
        target: root
        property: "internalSimTime"
        from: 0.0
        to: 1000000.0
        duration: 1000000000
        loops: Animation.Infinite
        running: true
    }

    // Apply speed scaling declaratively
    property real simTime: internalSimTime * (activeConfig.animationSpeed !== undefined ? activeConfig.animationSpeed : 1.0)

    // Count total cells
    property int totalCellsCount: root.columnsCount * (Math.ceil(root.height / root.colWidth) + 3)

    // Separate low-frequency timer for text symbol updates (drops CPU from 170% to 15%)
    Timer {
        interval: 33 // ~30 fps update loop for picking random cells
        running: activeConfig.animationSpeed !== undefined ? activeConfig.animationSpeed > 0 : true
        repeat: true
        onTriggered: {
            // WebGL cycleSpeed is 0.03 per 60fps frame, which is ~1.8 changes per second per cell.
            // We run at ~30fps (33ms interval), so we want 1.8 * count total changes per sec.
            // Per tick, we update: (1.8 * count) / 30 cells.
            let changesPerTick = Math.max(1, Math.floor((1.8 * root.totalCellsCount) / 30));
            for (let i = 0; i < changesPerTick; i++) {
                let randomCol = Math.floor(Math.random() * columnsRepeater.count);
                let colItem = columnsRepeater.itemAt(randomCol);
                if (colItem) {
                    // Because trailRepeater is inside the colItem, we need to access its items
                    // We can't easily query Repeater inside Repeater without an id.
                    // Let's just expose a function on the columnItem.
                    colItem.randomizeRandomCell();
                }
            }
        }
    }

    // Trigger config updates periodically instead of every frame
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
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
