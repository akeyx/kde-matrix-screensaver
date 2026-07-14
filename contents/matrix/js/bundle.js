(() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __require = /* @__PURE__ */ ((x) => typeof require !== "undefined" ? require : typeof Proxy !== "undefined" ? new Proxy(x, {
    get: (a, b) => (typeof require !== "undefined" ? require : a)[b]
  }) : x)(function(x) {
    if (typeof require !== "undefined")
      return require.apply(this, arguments);
    throw Error('Dynamic require of "' + x + '" is not supported');
  });
  var __esm = (fn, res) => function __init() {
    return fn && (res = (0, fn[__getOwnPropNames(fn)[0]])(fn = 0)), res;
  };
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };

  // contents/matrix/lib/holoplaycore.module.js
  var holoplaycore_module_exports = {};
  __export(holoplaycore_module_exports, {
    CacheMessage: () => CacheMessage,
    CheckMessage: () => CheckMessage,
    Client: () => Client,
    DeleteMessage: () => DeleteMessage,
    InfoMessage: () => InfoMessage,
    InitMessage: () => InitMessage,
    Message: () => Message,
    ShaderMessage: () => ShaderMessage,
    ShowCachedMessage: () => ShowCachedMessage,
    ShowMessage: () => ShowMessage,
    UniformsMessage: () => UniformsMessage,
    WipeMessage: () => WipeMessage
  });
  function createCommonjsModule(fn, module) {
    return module = { exports: {} }, fn(module, module.exports), module.exports;
  }
  function generateRng() {
    function xmur3(str) {
      for (var i = 0, h = 1779033703 ^ str.length; i < str.length; i++)
        h = Math.imul(h ^ str.charCodeAt(i), 3432918353), h = h << 13 | h >>> 19;
      return function() {
        h = Math.imul(h ^ h >>> 16, 2246822507);
        h = Math.imul(h ^ h >>> 13, 3266489909);
        return (h ^= h >>> 16) >>> 0;
      };
    }
    function xoshiro128ss(a, b, c, d) {
      return () => {
        var t = b << 9, r = a * 5;
        r = (r << 7 | r >>> 25) * 9;
        c ^= a;
        d ^= b;
        b ^= c;
        a ^= d;
        c ^= t;
        d = d << 11 | d >>> 21;
        return (r >>> 0) / 4294967296;
      };
    }
    var state = Date.now();
    var seed = xmur3(state.toString());
    return xoshiro128ss(seed(), seed(), seed(), seed());
  }
  var commonjsGlobal, cbor, WebSocket, Client, Message, InitMessage, DeleteMessage, CheckMessage, WipeMessage, InfoMessage, UniformsMessage, ShaderMessage, ShowMessage, CacheMessage, ShowCachedMessage;
  var init_holoplaycore_module = __esm({
    "contents/matrix/lib/holoplaycore.module.js"() {
      commonjsGlobal = typeof globalThis !== "undefined" ? globalThis : typeof window !== "undefined" ? window : typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : {};
      cbor = createCommonjsModule(function(module) {
        (function(global2, undefined$1) {
          var POW_2_24 = Math.pow(2, -24), POW_2_32 = Math.pow(2, 32), POW_2_53 = Math.pow(2, 53);
          function encode(value) {
            var data = new ArrayBuffer(256);
            var dataView = new DataView(data);
            var lastLength;
            var offset = 0;
            function ensureSpace(length) {
              var newByteLength = data.byteLength;
              var requiredLength = offset + length;
              while (newByteLength < requiredLength)
                newByteLength *= 2;
              if (newByteLength !== data.byteLength) {
                var oldDataView = dataView;
                data = new ArrayBuffer(newByteLength);
                dataView = new DataView(data);
                var uint32count = offset + 3 >> 2;
                for (var i2 = 0; i2 < uint32count; ++i2)
                  dataView.setUint32(i2 * 4, oldDataView.getUint32(i2 * 4));
              }
              lastLength = length;
              return dataView;
            }
            function write() {
              offset += lastLength;
            }
            function writeFloat64(value2) {
              write(ensureSpace(8).setFloat64(offset, value2));
            }
            function writeUint8(value2) {
              write(ensureSpace(1).setUint8(offset, value2));
            }
            function writeUint8Array(value2) {
              var dataView2 = ensureSpace(value2.length);
              for (var i2 = 0; i2 < value2.length; ++i2)
                dataView2.setUint8(offset + i2, value2[i2]);
              write();
            }
            function writeUint16(value2) {
              write(ensureSpace(2).setUint16(offset, value2));
            }
            function writeUint32(value2) {
              write(ensureSpace(4).setUint32(offset, value2));
            }
            function writeUint64(value2) {
              var low = value2 % POW_2_32;
              var high = (value2 - low) / POW_2_32;
              var dataView2 = ensureSpace(8);
              dataView2.setUint32(offset, high);
              dataView2.setUint32(offset + 4, low);
              write();
            }
            function writeTypeAndLength(type, length) {
              if (length < 24) {
                writeUint8(type << 5 | length);
              } else if (length < 256) {
                writeUint8(type << 5 | 24);
                writeUint8(length);
              } else if (length < 65536) {
                writeUint8(type << 5 | 25);
                writeUint16(length);
              } else if (length < 4294967296) {
                writeUint8(type << 5 | 26);
                writeUint32(length);
              } else {
                writeUint8(type << 5 | 27);
                writeUint64(length);
              }
            }
            function encodeItem(value2) {
              var i2;
              if (value2 === false)
                return writeUint8(244);
              if (value2 === true)
                return writeUint8(245);
              if (value2 === null)
                return writeUint8(246);
              if (value2 === undefined$1)
                return writeUint8(247);
              switch (typeof value2) {
                case "number":
                  if (Math.floor(value2) === value2) {
                    if (0 <= value2 && value2 <= POW_2_53)
                      return writeTypeAndLength(0, value2);
                    if (-POW_2_53 <= value2 && value2 < 0)
                      return writeTypeAndLength(1, -(value2 + 1));
                  }
                  writeUint8(251);
                  return writeFloat64(value2);
                case "string":
                  var utf8data = [];
                  for (i2 = 0; i2 < value2.length; ++i2) {
                    var charCode = value2.charCodeAt(i2);
                    if (charCode < 128) {
                      utf8data.push(charCode);
                    } else if (charCode < 2048) {
                      utf8data.push(192 | charCode >> 6);
                      utf8data.push(128 | charCode & 63);
                    } else if (charCode < 55296) {
                      utf8data.push(224 | charCode >> 12);
                      utf8data.push(128 | charCode >> 6 & 63);
                      utf8data.push(128 | charCode & 63);
                    } else {
                      charCode = (charCode & 1023) << 10;
                      charCode |= value2.charCodeAt(++i2) & 1023;
                      charCode += 65536;
                      utf8data.push(240 | charCode >> 18);
                      utf8data.push(128 | charCode >> 12 & 63);
                      utf8data.push(128 | charCode >> 6 & 63);
                      utf8data.push(128 | charCode & 63);
                    }
                  }
                  writeTypeAndLength(3, utf8data.length);
                  return writeUint8Array(utf8data);
                default:
                  var length;
                  if (Array.isArray(value2)) {
                    length = value2.length;
                    writeTypeAndLength(4, length);
                    for (i2 = 0; i2 < length; ++i2)
                      encodeItem(value2[i2]);
                  } else if (value2 instanceof Uint8Array) {
                    writeTypeAndLength(2, value2.length);
                    writeUint8Array(value2);
                  } else {
                    var keys = Object.keys(value2);
                    length = keys.length;
                    writeTypeAndLength(5, length);
                    for (i2 = 0; i2 < length; ++i2) {
                      var key = keys[i2];
                      encodeItem(key);
                      encodeItem(value2[key]);
                    }
                  }
              }
            }
            encodeItem(value);
            if ("slice" in data)
              return data.slice(0, offset);
            var ret = new ArrayBuffer(offset);
            var retView = new DataView(ret);
            for (var i = 0; i < offset; ++i)
              retView.setUint8(i, dataView.getUint8(i));
            return ret;
          }
          function decode(data, tagger, simpleValue) {
            var dataView = new DataView(data);
            var offset = 0;
            if (typeof tagger !== "function")
              tagger = function(value) {
                return value;
              };
            if (typeof simpleValue !== "function")
              simpleValue = function() {
                return undefined$1;
              };
            function read(value, length) {
              offset += length;
              return value;
            }
            function readArrayBuffer(length) {
              return read(new Uint8Array(data, offset, length), length);
            }
            function readFloat16() {
              var tempArrayBuffer = new ArrayBuffer(4);
              var tempDataView = new DataView(tempArrayBuffer);
              var value = readUint16();
              var sign = value & 32768;
              var exponent = value & 31744;
              var fraction = value & 1023;
              if (exponent === 31744)
                exponent = 255 << 10;
              else if (exponent !== 0)
                exponent += 127 - 15 << 10;
              else if (fraction !== 0)
                return fraction * POW_2_24;
              tempDataView.setUint32(0, sign << 16 | exponent << 13 | fraction << 13);
              return tempDataView.getFloat32(0);
            }
            function readFloat32() {
              return read(dataView.getFloat32(offset), 4);
            }
            function readFloat64() {
              return read(dataView.getFloat64(offset), 8);
            }
            function readUint8() {
              return read(dataView.getUint8(offset), 1);
            }
            function readUint16() {
              return read(dataView.getUint16(offset), 2);
            }
            function readUint32() {
              return read(dataView.getUint32(offset), 4);
            }
            function readUint64() {
              return readUint32() * POW_2_32 + readUint32();
            }
            function readBreak() {
              if (dataView.getUint8(offset) !== 255)
                return false;
              offset += 1;
              return true;
            }
            function readLength(additionalInformation) {
              if (additionalInformation < 24)
                return additionalInformation;
              if (additionalInformation === 24)
                return readUint8();
              if (additionalInformation === 25)
                return readUint16();
              if (additionalInformation === 26)
                return readUint32();
              if (additionalInformation === 27)
                return readUint64();
              if (additionalInformation === 31)
                return -1;
              throw "Invalid length encoding";
            }
            function readIndefiniteStringLength(majorType) {
              var initialByte = readUint8();
              if (initialByte === 255)
                return -1;
              var length = readLength(initialByte & 31);
              if (length < 0 || initialByte >> 5 !== majorType)
                throw "Invalid indefinite length element";
              return length;
            }
            function appendUtf16data(utf16data, length) {
              for (var i = 0; i < length; ++i) {
                var value = readUint8();
                if (value & 128) {
                  if (value < 224) {
                    value = (value & 31) << 6 | readUint8() & 63;
                    length -= 1;
                  } else if (value < 240) {
                    value = (value & 15) << 12 | (readUint8() & 63) << 6 | readUint8() & 63;
                    length -= 2;
                  } else {
                    value = (value & 15) << 18 | (readUint8() & 63) << 12 | (readUint8() & 63) << 6 | readUint8() & 63;
                    length -= 3;
                  }
                }
                if (value < 65536) {
                  utf16data.push(value);
                } else {
                  value -= 65536;
                  utf16data.push(55296 | value >> 10);
                  utf16data.push(56320 | value & 1023);
                }
              }
            }
            function decodeItem() {
              var initialByte = readUint8();
              var majorType = initialByte >> 5;
              var additionalInformation = initialByte & 31;
              var i;
              var length;
              if (majorType === 7) {
                switch (additionalInformation) {
                  case 25:
                    return readFloat16();
                  case 26:
                    return readFloat32();
                  case 27:
                    return readFloat64();
                }
              }
              length = readLength(additionalInformation);
              if (length < 0 && (majorType < 2 || 6 < majorType))
                throw "Invalid length";
              switch (majorType) {
                case 0:
                  return length;
                case 1:
                  return -1 - length;
                case 2:
                  if (length < 0) {
                    var elements = [];
                    var fullArrayLength = 0;
                    while ((length = readIndefiniteStringLength(majorType)) >= 0) {
                      fullArrayLength += length;
                      elements.push(readArrayBuffer(length));
                    }
                    var fullArray = new Uint8Array(fullArrayLength);
                    var fullArrayOffset = 0;
                    for (i = 0; i < elements.length; ++i) {
                      fullArray.set(elements[i], fullArrayOffset);
                      fullArrayOffset += elements[i].length;
                    }
                    return fullArray;
                  }
                  return readArrayBuffer(length);
                case 3:
                  var utf16data = [];
                  if (length < 0) {
                    while ((length = readIndefiniteStringLength(majorType)) >= 0)
                      appendUtf16data(utf16data, length);
                  } else
                    appendUtf16data(utf16data, length);
                  return String.fromCharCode.apply(null, utf16data);
                case 4:
                  var retArray;
                  if (length < 0) {
                    retArray = [];
                    while (!readBreak())
                      retArray.push(decodeItem());
                  } else {
                    retArray = new Array(length);
                    for (i = 0; i < length; ++i)
                      retArray[i] = decodeItem();
                  }
                  return retArray;
                case 5:
                  var retObject = {};
                  for (i = 0; i < length || length < 0 && !readBreak(); ++i) {
                    var key = decodeItem();
                    retObject[key] = decodeItem();
                  }
                  return retObject;
                case 6:
                  return tagger(decodeItem(), length);
                case 7:
                  switch (length) {
                    case 20:
                      return false;
                    case 21:
                      return true;
                    case 22:
                      return null;
                    case 23:
                      return undefined$1;
                    default:
                      return simpleValue(length);
                  }
              }
            }
            var ret = decodeItem();
            if (offset !== data.byteLength)
              throw "Remaining bytes";
            return ret;
          }
          var obj = { encode, decode };
          if (typeof undefined$1 === "function" && undefined$1.amd)
            undefined$1("cbor/cbor", obj);
          else if (module.exports)
            module.exports = obj;
          else if (!global2.CBOR)
            global2.CBOR = obj;
        })(commonjsGlobal);
      });
      WebSocket = typeof window === "undefined" ? __require("ws") : window.WebSocket;
      Client = class {
        /**
         * Establish a client to talk to HoloPlayService.
         * @constructor
         * @param {function} initCallback - optional; a function to trigger when
         *     response is received
         * @param {function} errCallback - optional; a function to trigger when there
         *     is a connection error
         * @param {function} closeCallback - optional; a function to trigger when the
         *     socket is closed
         * @param {boolean} debug - optional; default is false
         * @param {string}  appId - optional
         * @param {boolean} isGreedy - optional
         * @param {string}  oncloseBehavior - optional, can be 'wipe', 'hide', 'none'
         */
        constructor(initCallback, errCallback, closeCallback, debug = false, appId, isGreedy, oncloseBehavior) {
          this.reqs = [];
          this.reps = [];
          this.requestId = this.getRequestId();
          this.debug = debug;
          this.isGreedy = isGreedy;
          this.errCallback = errCallback;
          this.closeCallback = closeCallback;
          this.alwaysdebug = false;
          this.isConnected = false;
          let initCmd = null;
          if (appId || isGreedy || oncloseBehavior) {
            initCmd = new InitMessage(appId, isGreedy, oncloseBehavior, this.debug);
          } else {
            if (debug)
              this.alwaysdebug = true;
            if (typeof initCallback == "function")
              initCmd = new InfoMessage();
          }
          this.openWebsocket(initCmd, initCallback);
        }
        /**
         * Send a message over the websocket to HoloPlayService.
         * @public
         * @param {Message} msg - message object
         * @param {integer} timeoutSecs - optional, default is 60 seconds
         */
        sendMessage(msg, timeoutSecs = 60) {
          if (this.alwaysdebug)
            msg.cmd.debug = true;
          let cborData = msg.toCbor();
          return this.sendRequestObj(cborData, timeoutSecs);
        }
        /**
         * Disconnects from the web socket.
         * @public
         */
        disconnect() {
          this.ws.close();
        }
        /**
         * Open a websocket and set handlers
         * @private
         */
        openWebsocket(firstCmd = null, initCallback = null) {
          this.ws = new WebSocket("ws://localhost:11222/driver", ["rep.sp.nanomsg.org"]);
          this.ws.parent = this;
          this.ws.binaryType = "arraybuffer";
          this.ws.onmessage = this.messageHandler;
          this.ws.onopen = () => {
            this.isConnected = true;
            if (this.debug) {
              console.log("socket open");
            }
            if (firstCmd != null) {
              this.sendMessage(firstCmd).then(initCallback);
            }
          };
          this.ws.onerror = this.onSocketError;
          this.ws.onclose = this.onClose;
        }
        /**
         * Send a request object over websocket
         * @private
         */
        sendRequestObj(data, timeoutSecs) {
          return new Promise((resolve, reject) => {
            let reqObj = {
              id: this.requestId++,
              parent: this,
              payload: data,
              success: resolve,
              error: reject,
              send: function() {
                if (this.debug)
                  console.log("attemtping to send request with ID " + this.id);
                this.timeout = setTimeout(reqObj.send.bind(this), timeoutSecs * 1e3);
                let tmp = new Uint8Array(data.byteLength + 4);
                let view = new DataView(tmp.buffer);
                view.setUint32(0, this.id);
                tmp.set(new Uint8Array(this.payload), 4);
                this.parent.ws.send(tmp.buffer);
              }
            };
            this.reqs.push(reqObj);
            reqObj.send();
          });
        }
        /**
         * Handles a message when received
         * @private
         */
        messageHandler(event) {
          console.log("message");
          let data = event.data;
          if (data.byteLength < 4)
            return;
          let view = new DataView(data);
          let replyId = view.getUint32(0);
          if (replyId < 2147483648) {
            this.parent.err("bad nng header");
            return;
          }
          let i = this.parent.findReqIndex(replyId);
          if (i == -1) {
            this.parent.err("got reply that doesn't match known request!");
            return;
          }
          let rep = { id: replyId, payload: cbor.decode(data.slice(4)) };
          if (rep.payload.error == 0) {
            this.parent.reqs[i].success(rep.payload);
          } else {
            this.parent.reqs[i].error(rep.payload);
          }
          clearTimeout(this.parent.reqs[i].timeout);
          this.parent.reqs.splice(i, 1);
          this.parent.reps.push(rep);
          if (this.debug) {
            console.log(rep.payload);
          }
        }
        getRequestId() {
          return Math.floor(this.prng() * 2147483647) + 2147483648;
        }
        onClose(event) {
          this.parent.isConnected = false;
          if (this.parent.debug) {
            console.log("socket closed");
          }
          if (typeof this.parent.closeCallback == "function")
            this.parent.closeCallback(event);
        }
        onSocketError(error) {
          if (this.parent.debug) {
            console.log(error);
          }
          if (typeof this.parent.errCallback == "function") {
            this.parent.errCallback(error);
          }
        }
        err(errorMsg) {
          if (this.debug) {
            console.log("[DRIVER ERROR]" + errorMsg);
          }
        }
        findReqIndex(replyId) {
          let i = 0;
          for (; i < this.reqs.length; i++) {
            if (this.reqs[i].id == replyId) {
              return i;
            }
          }
          return -1;
        }
        prng() {
          if (this.rng == void 0) {
            this.rng = generateRng();
          }
          return this.rng();
        }
      };
      Message = class {
        /**
         * Construct a barebone message.
         * @constructor
         */
        constructor(cmd, bin) {
          this.cmd = cmd;
          this.bin = bin;
        }
        /**
         * Convert the class instance to the CBOR format
         * @public
         * @returns {CBOR} - cbor object of the message
         */
        toCbor() {
          return cbor.encode(this);
        }
      };
      InitMessage = class extends Message {
        /**
         * @constructor
         * @param {string}  appId - a unique id for app
         * @param {boolean} isGreedy - will it take over screen
         * @param {string}  oncloseBehavior - can be 'wipe', 'hide', 'none'
         */
        constructor(appId = "", isGreedy = false, onclose = "", debug = false) {
          let cmd = { "init": {} };
          if (appId != "")
            cmd["init"].appid = appId;
          if (onclose != "")
            cmd["init"].onclose = onclose;
          if (isGreedy)
            cmd["init"].greedy = true;
          if (debug)
            cmd["init"].debug = true;
          super(cmd, null);
        }
      };
      DeleteMessage = class extends Message {
        /**
         * @constructor
         * @param {string} name - name of the quilt
         */
        constructor(name = "") {
          let cmd = { "delete": { "name": name } };
          super(cmd, null);
        }
      };
      CheckMessage = class extends Message {
        /**
         * @constructor
         * @param {string} name - name of the quilt
         */
        constructor(name = "") {
          let cmd = { "check": { "name": name } };
          super(cmd, null);
        }
      };
      WipeMessage = class extends Message {
        /**
         * @constructor
         * @param {number} targetDisplay - optional, if not provided, default is 0
         */
        constructor(targetDisplay = null) {
          let cmd = { "wipe": {} };
          if (targetDisplay != null)
            cmd["wipe"].targetDisplay = targetDisplay;
          super(cmd, null);
        }
      };
      InfoMessage = class extends Message {
        /**
         * @constructor
         */
        constructor() {
          let cmd = { "info": {} };
          super(cmd, null);
        }
      };
      UniformsMessage = class extends Message {
        /**
         * @constructor
         * @param {object}
         */
        constructor() {
          let cmd = { "uniforms": {} };
          super(cmd, bindata);
        }
      };
      ShaderMessage = class extends Message {
        /**
         * @constructor
         * @param {object}
         */
        constructor() {
          let cmd = { "shader": {} };
          super(cmd, bindata);
        }
      };
      ShowMessage = class extends Message {
        /**
         * @constructor
         * @param {object}
         */
        constructor(settings = { vx: 5, vy: 9, aspect: 1.6 }, bindata2 = "", targetDisplay = null) {
          let cmd = {
            "show": {
              "source": "bindata",
              "quilt": { "type": "image", "settings": settings }
            }
          };
          if (targetDisplay != null)
            cmd["show"]["targetDisplay"] = targetDisplay;
          super(cmd, bindata2);
        }
      };
      CacheMessage = class extends Message {
        constructor(name, settings = { vx: 5, vy: 9, aspect: 1.6 }, bindata2 = "", show = false) {
          let cmd = {
            "cache": {
              "show": show,
              "quilt": {
                "name": name,
                "type": "image",
                "settings": settings
              }
            }
          };
          super(cmd, bindata2);
        }
      };
      ShowCachedMessage = class extends Message {
        constructor(name, targetDisplay = null, settings = null) {
          let cmd = { "show": { "source": "cache", "quilt": { "name": name } } };
          if (targetDisplay != null)
            cmd["show"]["targetDisplay"] = targetDisplay;
          if (settings != null)
            cmd["show"]["quilt"].settings = settings;
          super(cmd, null);
        }
      };
    }
  });

  // contents/matrix/js/config.js
  var fonts = {
    coptic: {
      // The script the Gnostic codices were written in
      glyphMSDFURL: "assets/coptic_msdf.png",
      glyphSequenceLength: 32,
      glyphTextureGridSize: [8, 8]
    },
    gothic: {
      // The script the Codex Argenteus was written in
      glyphMSDFURL: "assets/gothic_msdf.png",
      glyphSequenceLength: 27,
      glyphTextureGridSize: [8, 8]
    },
    matrixcode: {
      // The glyphs seen in the film trilogy
      glyphMSDFURL: "assets/matrixcode_msdf.png",
      glyphSequenceLength: 57,
      glyphTextureGridSize: [8, 8]
    },
    megacity: {
      // The glyphs seen in the film trilogy
      glyphMSDFURL: "assets/megacity_msdf.png",
      glyphSequenceLength: 64,
      glyphTextureGridSize: [8, 8]
    },
    resurrections: {
      // The glyphs seen in the film trilogy
      glyphMSDFURL: "assets/resurrections_msdf.png",
      glintMSDFURL: "assets/resurrections_glint_msdf.png",
      glyphSequenceLength: 135,
      glyphTextureGridSize: [13, 12]
    },
    huberfishA: {
      glyphMSDFURL: "assets/huberfish_a_msdf.png",
      glyphSequenceLength: 34,
      glyphTextureGridSize: [6, 6]
    },
    huberfishD: {
      glyphMSDFURL: "assets/huberfish_d_msdf.png",
      glyphSequenceLength: 34,
      glyphTextureGridSize: [6, 6]
    },
    gtarg_tenretniolleh: {
      glyphMSDFURL: "assets/gtarg_tenretniolleh_msdf.png",
      glyphSequenceLength: 36,
      glyphTextureGridSize: [6, 6]
    },
    gtarg_alientext: {
      glyphMSDFURL: "assets/gtarg_alientext_msdf.png",
      glyphSequenceLength: 38,
      glyphTextureGridSize: [8, 5]
    },
    neomatrixology: {
      glyphMSDFURL: "assets/neomatrixology_msdf.png",
      glyphSequenceLength: 12,
      glyphTextureGridSize: [4, 4]
    }
  };
  var textureURLs = {
    sand: "assets/sand.png",
    pixels: "assets/pixel_grid.png",
    mesh: "assets/mesh.png",
    metal: "assets/metal.png"
  };
  var hsl = (...values) => ({ space: "hsl", values });
  var defaults = {
    font: "matrixcode",
    effect: "palette",
    // The name of the effect to apply at the end of the process— mainly handles coloration
    baseTexture: null,
    // The name of the texture to apply to the base layer of the glyphs
    glintTexture: null,
    // The name of the texture to apply to the glint layer of the glyphs
    useCamera: false,
    backgroundColor: hsl(0, 0, 0),
    // The color "behind" the glyphs
    isolateCursor: true,
    // Whether the "cursor"— the brightest glyph at the bottom of a raindrop— has its own color
    cursorColor: hsl(0.242, 1, 0.73),
    // The color of the cursor
    cursorIntensity: 2,
    // The intensity of the cursor
    isolateGlint: false,
    // Whether the "glint"— highlights on certain symbols in the font— should appear
    glintColor: hsl(0, 0, 1),
    // The color of the glint
    glintIntensity: 1,
    // The intensity of the glint
    volumetric: false,
    // A mode where the raindrops appear in perspective
    animationSpeed: 1,
    // The global rate that all animations progress
    fps: 60,
    // The target frame rate (frames per second) of the effect
    forwardSpeed: 0.25,
    // The speed volumetric rain approaches the eye
    bloomStrength: 0.7,
    // The intensity of the bloom
    bloomSize: 0.4,
    // The amount the bloom calculation is scaled
    highPassThreshold: 0.1,
    // The minimum brightness that is still blurred
    cycleSpeed: 0.03,
    // The speed glyphs change
    cycleFrameSkip: 1,
    // The global minimum number of frames between glyphs cycling
    baseBrightness: -0.5,
    // The brightness of the glyphs, before any effects are applied
    baseContrast: 1.1,
    // The contrast of the glyphs, before any effects are applied
    glintBrightness: -1.5,
    // The brightness of the glints, before any effects are applied
    glintContrast: 2.5,
    // The contrast of the glints, before any effects are applied
    brightnessOverride: 0,
    // A global override to the brightness of displayed glyphs. Only used if it is > 0.
    brightnessThreshold: 0,
    // The minimum brightness for a glyph to still be considered visible
    brightnessDecay: 1,
    // The rate at which glyphs light up and dim
    ditherMagnitude: 0.05,
    // The magnitude of the random per-pixel dimming
    fallSpeed: 0.3,
    // The speed the raindrops progress downwards
    glyphEdgeCrop: 0,
    // The border around a glyph in a font texture that should be cropped out
    glyphHeightToWidth: 1,
    // The aspect ratio of glyphs
    glyphVerticalSpacing: 1,
    // The ratio of the vertical distance between glyphs to their height
    glyphFlip: false,
    // Whether to horizontally reflect the glyphs
    glyphRotation: 0,
    // An angle to rotate the glyphs. Currently limited to 90° increments
    hasThunder: false,
    // An effect that adds dramatic lightning flashes
    isPolar: false,
    // Whether the glyphs arc across the screen or sit in a standard grid
    rippleTypeName: null,
    // The variety of the ripple effect
    rippleThickness: 0.2,
    // The thickness of the ripple effect
    rippleScale: 30,
    // The size of the ripple effect
    rippleSpeed: 0.2,
    // The rate at which the ripple effect progresses
    numColumns: 80,
    // The maximum dimension of the glyph grid
    density: 1,
    // In volumetric mode, the number of actual columns compared to the grid
    palette: [
      // The color palette that glyph brightness is color mapped to
      { color: hsl(0.3, 0.9, 0), at: 0 },
      { color: hsl(0.3, 0.9, 0.2), at: 0.2 },
      { color: hsl(0.3, 0.9, 0.7), at: 0.7 },
      { color: hsl(0.3, 0.9, 0.8), at: 0.8 }
    ],
    raindropLength: 0.75,
    // Adjusts the frequency of raindrops (and their length) in a column
    slant: 0,
    // The angle at which rain falls; the orientation of the glyph grid
    resolution: 0.75,
    // An overall scale multiplier
    useHalfFloat: false,
    renderer: "regl",
    // The preferred web graphics API
    suppressWarnings: false,
    // Whether to show warnings to visitors on load
    isometric: false,
    useHoloplay: false,
    loops: false,
    skipIntro: true,
    testFix: null
  };
  var versions = {
    classic: {},
    megacity: {
      font: "megacity",
      animationSpeed: 0.5,
      numColumns: 40
    },
    neomatrixology: {
      font: "neomatrixology",
      animationSpeed: 0.8,
      numColumns: 40,
      palette: [
        { color: hsl(0.15, 0.9, 0), at: 0 },
        { color: hsl(0.15, 0.9, 0.2), at: 0.2 },
        { color: hsl(0.15, 0.9, 0.7), at: 0.7 },
        { color: hsl(0.15, 0.9, 0.8), at: 0.8 }
      ],
      cursorColor: hsl(0.167, 1, 0.75),
      cursorIntensity: 2
    },
    operator: {
      cursorColor: hsl(0.375, 1, 0.66),
      cursorIntensity: 3,
      bloomSize: 0.6,
      bloomStrength: 0.75,
      highPassThreshold: 0,
      cycleSpeed: 0.01,
      cycleFrameSkip: 8,
      brightnessOverride: 0.22,
      brightnessThreshold: 0,
      fallSpeed: 0.6,
      glyphEdgeCrop: 0.15,
      glyphHeightToWidth: 1.35,
      rippleTypeName: "box",
      numColumns: 108,
      palette: [
        { color: hsl(0.4, 0.8, 0), at: 0 },
        { color: hsl(0.4, 0.8, 0.5), at: 0.5 },
        { color: hsl(0.4, 0.8, 1), at: 1 }
      ],
      raindropLength: 1.5
    },
    nightmare: {
      font: "gothic",
      isolateCursor: false,
      highPassThreshold: 0.7,
      baseBrightness: -0.8,
      brightnessDecay: 0.75,
      fallSpeed: 1.2,
      hasThunder: true,
      numColumns: 60,
      cycleSpeed: 0.35,
      palette: [
        { color: hsl(0, 1, 0), at: 0 },
        { color: hsl(0, 1, 0.2), at: 0.2 },
        { color: hsl(0, 1, 0.4), at: 0.4 },
        { color: hsl(0.1, 1, 0.7), at: 0.7 },
        { color: hsl(0.2, 1, 1), at: 1 }
      ],
      raindropLength: 0.5,
      slant: 22.5 * Math.PI / 180
    },
    paradise: {
      font: "coptic",
      isolateCursor: false,
      bloomStrength: 1,
      highPassThreshold: 0,
      cycleSpeed: 5e-3,
      baseBrightness: -1.3,
      baseContrast: 2,
      brightnessDecay: 0.05,
      fallSpeed: 0.02,
      isPolar: true,
      rippleTypeName: "circle",
      rippleSpeed: 0.1,
      numColumns: 40,
      palette: [
        { color: hsl(0, 0, 0), at: 0 },
        { color: hsl(0, 0.8, 0.3), at: 0.3 },
        { color: hsl(0.1, 0.8, 0.5), at: 0.5 },
        { color: hsl(0.1, 1, 0.6), at: 0.6 },
        { color: hsl(0.1, 1, 0.9), at: 0.9 }
      ],
      raindropLength: 0.4
    },
    resurrections: {
      font: "resurrections",
      glyphEdgeCrop: 0.1,
      cursorColor: hsl(0.292, 1, 0.8),
      cursorIntensity: 2,
      baseBrightness: -0.7,
      baseContrast: 1.17,
      highPassThreshold: 0,
      numColumns: 70,
      cycleSpeed: 0.03,
      bloomStrength: 0.7,
      fallSpeed: 0.3,
      palette: [
        { color: hsl(0.375, 0.9, 0), at: 0 },
        { color: hsl(0.375, 1, 0.6), at: 0.92 },
        { color: hsl(0.375, 1, 1), at: 1 }
      ]
    },
    trinity: {
      font: "resurrections",
      glintTexture: "metal",
      baseTexture: "pixels",
      glyphEdgeCrop: 0.1,
      cursorColor: hsl(0.292, 1, 0.8),
      cursorIntensity: 2,
      isolateGlint: true,
      glintColor: hsl(0.131, 1, 0.6),
      glintIntensity: 3,
      glintBrightness: -0.5,
      glintContrast: 1.5,
      baseBrightness: -0.4,
      baseContrast: 1.5,
      highPassThreshold: 0,
      numColumns: 60,
      cycleSpeed: 0.03,
      bloomStrength: 0.7,
      fallSpeed: 0.3,
      palette: [
        { color: hsl(0.37, 0.6, 0), at: 0 },
        { color: hsl(0.37, 0.6, 0.5), at: 1 }
      ],
      cycleSpeed: 0.01,
      volumetric: true,
      forwardSpeed: 0.2,
      raindropLength: 0.3,
      density: 0.75
    },
    morpheus: {
      font: "resurrections",
      glintTexture: "mesh",
      baseTexture: "metal",
      glyphEdgeCrop: 0.1,
      cursorColor: hsl(0.333, 1, 0.85),
      cursorIntensity: 2,
      isolateGlint: true,
      glintColor: hsl(0.4, 1, 0.5),
      glintIntensity: 2,
      glintBrightness: -1.5,
      glintContrast: 3,
      baseBrightness: -0.3,
      baseContrast: 1.5,
      highPassThreshold: 0,
      numColumns: 60,
      cycleSpeed: 0.03,
      bloomStrength: 0.7,
      fallSpeed: 0.3,
      palette: [
        { color: hsl(0.97, 0.6, 0), at: 0 },
        { color: hsl(0.97, 0.6, 0.5), at: 1 }
      ],
      cycleSpeed: 0.015,
      volumetric: true,
      forwardSpeed: 0.1,
      raindropLength: 0.4,
      density: 0.75
    },
    bugs: {
      font: "resurrections",
      glintTexture: "sand",
      baseTexture: "metal",
      glyphEdgeCrop: 0.1,
      cursorColor: hsl(0.619, 1, 0.65),
      cursorIntensity: 2,
      isolateGlint: true,
      glintColor: hsl(0.625, 1, 0.6),
      glintIntensity: 3,
      glintBrightness: -1,
      glintContrast: 3,
      baseBrightness: -0.3,
      baseContrast: 1.5,
      highPassThreshold: 0,
      numColumns: 60,
      cycleSpeed: 0.03,
      bloomStrength: 0.7,
      fallSpeed: 0.3,
      palette: [
        { color: hsl(0.12, 0.6, 0), at: 0 },
        { color: hsl(0.14, 0.6, 0.5), at: 1 }
      ],
      cycleSpeed: 0.01,
      volumetric: true,
      forwardSpeed: 0.4,
      raindropLength: 0.3,
      density: 0.75
    },
    palimpsest: {
      font: "huberfishA",
      isolateCursor: false,
      bloomStrength: 0.2,
      numColumns: 40,
      raindropLength: 1.2,
      cycleFrameSkip: 3,
      fallSpeed: 0.5,
      slant: Math.PI * -0.0625,
      palette: [
        { color: hsl(0.15, 0.25, 0.9), at: 0 },
        { color: hsl(0.6, 0.8, 0.1), at: 0.4 }
      ]
    },
    twilight: {
      font: "huberfishD",
      cursorColor: hsl(0.167, 1, 0.8),
      cursorIntensity: 1.5,
      bloomStrength: 0.1,
      numColumns: 50,
      raindropLength: 0.9,
      fallSpeed: 0.1,
      highPassThreshold: 0,
      palette: [
        { color: hsl(0.6, 1, 0.05), at: 0 },
        { color: hsl(0.6, 0.8, 0.1), at: 0.1 },
        { color: hsl(0.88, 0.8, 0.5), at: 0.5 },
        { color: hsl(0.15, 1, 0.6), at: 0.8 }
        // { color: hsl(0.1, 1.0, 0.9), at: 1.0 },
      ]
    },
    holoplay: {
      font: "resurrections",
      glintTexture: "metal",
      glyphEdgeCrop: 0.1,
      cursorColor: hsl(0.292, 1, 0.8),
      cursorIntensity: 2,
      isolateGlint: true,
      glintColor: hsl(0.131, 1, 0.6),
      glintIntensity: 3,
      glintBrightness: -0.5,
      glintContrast: 1.5,
      baseBrightness: -0.4,
      baseContrast: 1.5,
      highPassThreshold: 0,
      cycleSpeed: 0.03,
      bloomStrength: 0.7,
      fallSpeed: 0.3,
      palette: [
        { color: hsl(0.37, 0.6, 0), at: 0 },
        { color: hsl(0.37, 0.6, 0.5), at: 1 }
      ],
      cycleSpeed: 0.01,
      raindropLength: 0.3,
      renderer: "regl",
      numColumns: 20,
      ditherMagnitude: 0,
      bloomStrength: 0,
      volumetric: true,
      forwardSpeed: 0,
      density: 3,
      useHoloplay: true
    },
    ["3d"]: {
      volumetric: true,
      fallSpeed: 0.5,
      cycleSpeed: 0.03,
      baseBrightness: -0.9,
      baseContrast: 1.5,
      raindropLength: 0.3
    }
  };
  versions.throwback = versions.operator;
  versions.updated = versions.resurrections;
  versions["1999"] = versions.operator;
  versions["2003"] = versions.classic;
  versions["2021"] = versions.resurrections;
  var range = (f, min = -Infinity, max = Infinity) => Math.max(min, Math.min(max, f));
  var nullNaN = (f) => isNaN(f) ? null : f;
  var isTrue = (s) => s.toLowerCase().includes("true");
  var parseColor = (isHSL) => (s) => ({
    space: isHSL ? "hsl" : "rgb",
    values: s.split(",").map(parseFloat)
  });
  var parseColors = (isHSL) => (s) => {
    const values = s.split(",").map(parseFloat);
    const space = isHSL ? "hsl" : "rgb";
    return Array(Math.floor(values.length / 3)).fill().map((_, index2) => ({
      space,
      values: values.slice(index2 * 3, (index2 + 1) * 3)
    }));
  };
  var parsePalette = (isHSL) => (s) => {
    const values = s.split(",").map(parseFloat);
    const space = isHSL ? "hsl" : "rgb";
    return Array(Math.floor(values.length / 4)).fill().map((_, index2) => {
      const colorValues = values.slice(index2 * 4, (index2 + 1) * 4);
      return {
        color: {
          space,
          values: colorValues.slice(0, 3)
        },
        at: colorValues[3]
      };
    });
  };
  var paramMapping = {
    testFix: { key: "testFix", parser: (s) => s },
    version: { key: "version", parser: (s) => s },
    font: { key: "font", parser: (s) => s },
    effect: { key: "effect", parser: (s) => s },
    camera: { key: "useCamera", parser: isTrue },
    numColumns: { key: "numColumns", parser: (s) => nullNaN(parseInt(s)) },
    density: { key: "density", parser: (s) => nullNaN(range(parseFloat(s), 0)) },
    resolution: { key: "resolution", parser: (s) => nullNaN(parseFloat(s)) },
    animationSpeed: {
      key: "animationSpeed",
      parser: (s) => nullNaN(parseFloat(s))
    },
    forwardSpeed: {
      key: "forwardSpeed",
      parser: (s) => nullNaN(parseFloat(s))
    },
    cycleSpeed: { key: "cycleSpeed", parser: (s) => nullNaN(parseFloat(s)) },
    fallSpeed: { key: "fallSpeed", parser: (s) => nullNaN(parseFloat(s)) },
    raindropLength: {
      key: "raindropLength",
      parser: (s) => nullNaN(parseFloat(s))
    },
    slant: {
      key: "slant",
      parser: (s) => nullNaN(parseFloat(s) * Math.PI / 180)
    },
    bloomSize: {
      key: "bloomSize",
      parser: (s) => nullNaN(range(parseFloat(s), 0, 1))
    },
    bloomStrength: {
      key: "bloomStrength",
      parser: (s) => nullNaN(range(parseFloat(s), 0, 1))
    },
    ditherMagnitude: {
      key: "ditherMagnitude",
      parser: (s) => nullNaN(range(parseFloat(s), 0, 1))
    },
    url: { key: "bgURL", parser: (s) => s },
    palette: { key: "palette", parser: parsePalette(false) },
    stripeColors: { key: "stripeColors", parser: parseColors(false) },
    backgroundColor: { key: "backgroundColor", parser: parseColor(false) },
    cursorColor: { key: "cursorColor", parser: parseColor(false) },
    glintColor: { key: "glintColor", parser: parseColor(false) },
    paletteHSL: { key: "palette", parser: parsePalette(true) },
    stripeHSL: { key: "stripeColors", parser: parseColors(true) },
    backgroundHSL: { key: "backgroundColor", parser: parseColor(true) },
    cursorHSL: { key: "cursorColor", parser: parseColor(true) },
    glintHSL: { key: "glintColor", parser: parseColor(true) },
    cursorIntensity: {
      key: "cursorIntensity",
      parser: (s) => nullNaN(range(parseFloat(s), 0, Infinity))
    },
    glyphIntensity: {
      key: "glyphIntensity",
      parser: (s) => nullNaN(range(parseFloat(s), 0, Infinity))
    },
    volumetric: { key: "volumetric", parser: isTrue },
    glyphFlip: { key: "glyphFlip", parser: isTrue },
    glyphRotation: {
      key: "glyphRotation",
      parser: (s) => nullNaN(range(parseFloat(s), 0, Infinity))
    },
    loops: { key: "loops", parser: isTrue },
    fps: { key: "fps", parser: (s) => nullNaN(range(parseFloat(s), 0, 60)) },
    skipIntro: { key: "skipIntro", parser: isTrue },
    renderer: { key: "renderer", parser: (s) => s },
    suppressWarnings: { key: "suppressWarnings", parser: isTrue },
    once: { key: "once", parser: isTrue },
    isometric: { key: "isometric", parser: isTrue }
  };
  paramMapping.paletteRGB = paramMapping.palette;
  paramMapping.stripeRGB = paramMapping.stripeColors;
  paramMapping.backgroundRGB = paramMapping.backgroundColor;
  paramMapping.cursorRGB = paramMapping.cursorColor;
  paramMapping.glintRGB = paramMapping.glintColor;
  paramMapping.width = paramMapping.numColumns;
  paramMapping.dropLength = paramMapping.raindropLength;
  paramMapping.angle = paramMapping.slant;
  paramMapping.colors = paramMapping.stripeColors;
  var config_default = (urlParams) => {
    const validParams = Object.fromEntries(
      Object.entries(urlParams).filter(([key]) => key in paramMapping).map(([key, value]) => [paramMapping[key].key, paramMapping[key].parser(value)]).filter(([_, value]) => value != null)
    );
    if (validParams.effect != null) {
      if (validParams.cursorColor == null) {
        validParams.cursorColor = hsl(0, 0, 1);
      }
      if (validParams.cursorIntensity == null) {
        validParams.cursorIntensity = 2;
      }
      if (validParams.glintColor == null) {
        validParams.glintColor = hsl(0, 0, 1);
      }
      if (validParams.glyphIntensity == null) {
        validParams.glyphIntensity = 1;
      }
    }
    const version = validParams.version in versions ? versions[validParams.version] : versions.classic;
    const fontName = [validParams.font, version.font, defaults.font].find((name) => name in fonts);
    const font = fonts[fontName];
    const baseTextureURL = textureURLs[[version.baseTexture, defaults.baseTexture].find((name) => name in textureURLs)];
    const hasBaseTexture = baseTextureURL != null;
    const glintTextureURL = textureURLs[[version.glintTexture, defaults.glintTexture].find((name) => name in textureURLs)];
    const hasGlintTexture = glintTextureURL != null;
    const config = {
      ...defaults,
      ...version,
      ...font,
      ...validParams,
      baseTextureURL,
      glintTextureURL,
      hasBaseTexture,
      hasGlintTexture
    };
    if (config.bloomSize <= 0) {
      config.bloomStrength = 0;
    }
    return config;
  };

  // contents/matrix/js/regl/utils.js
  var makePassTexture = (regl, halfFloat) => regl.texture({
    width: 1,
    height: 1,
    type: halfFloat ? "half float" : "uint8",
    wrap: "clamp",
    min: "linear",
    mag: "linear"
  });
  var makePassFBO = (regl, halfFloat) => regl.framebuffer({ color: makePassTexture(regl, halfFloat) });
  var makeDoubleBuffer = (regl, props) => {
    const state = Array(2).fill().map(
      () => regl.framebuffer({
        color: regl.texture(props),
        depthStencil: false
      })
    );
    return {
      front: ({ tick }) => state[tick % 2],
      back: ({ tick }) => state[(tick + 1) % 2]
    };
  };
  var isPowerOfTwo = (x) => Math.log2(x) % 1 == 0;
  var loadImage = (regl, url, mipmap) => {
    let texture = regl.texture([[0]]);
    let loaded = false;
    return {
      texture: () => {
        if (!loaded && url != null) {
          console.warn(`texture still loading: ${url}`);
        }
        return texture;
      },
      width: () => {
        if (!loaded && url != null) {
          console.warn(`texture still loading: ${url}`);
        }
        return loaded ? texture.width : 1;
      },
      height: () => {
        if (!loaded && url != null) {
          console.warn(`texture still loading: ${url}`);
        }
        return loaded ? texture.height : 1;
      },
      loaded: (async () => {
        if (url != null) {
          const data = new Image();
          data.crossOrigin = "anonymous";
          data.src = url;
          await data.decode();
          loaded = true;
          if (mipmap) {
            if (!isPowerOfTwo(data.width) || !isPowerOfTwo(data.height)) {
              console.warn(`Can't mipmap a non-power-of-two image: ${url}`);
            }
            mipmap = false;
          }
          texture = regl.texture({
            data,
            mag: "linear",
            min: mipmap ? "mipmap" : "linear",
            flipY: true
          });
        }
      })()
    };
  };
  var loadText = (url) => {
    let text = "";
    let loaded = false;
    return {
      text: () => {
        if (!loaded) {
          console.warn(`text still loading: ${url}`);
        }
        return text;
      },
      loaded: (async () => {
        if (url != null) {
          text = await (await fetch(url + "?t=" + Date.now())).text();
          loaded = true;
        }
      })()
    };
  };
  var makeFullScreenQuad = (regl, uniforms = {}, context2 = {}) => regl({
    vert: `
		precision mediump float;
		attribute vec2 aPosition;
		varying vec2 vUV;
		void main() {
			vUV = 0.5 * (aPosition + 1.0);
			gl_Position = vec4(aPosition, 0, 1);
		}
	`,
    frag: `
		precision mediump float;
		varying vec2 vUV;
		uniform sampler2D tex;
		void main() {
			gl_FragColor = texture2D(tex, vUV);
		}
	`,
    attributes: {
      aPosition: [-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]
    },
    count: 6,
    uniforms: {
      ...uniforms,
      time: regl.context("time"),
      tick: regl.context("tick")
    },
    context: context2,
    depth: { enable: false },
    cull: { enable: false }
  });
  var make1DTexture = (regl, rgbas) => {
    const data = rgbas.map((rgba) => rgba.map((f) => Math.floor(f * 255))).flat();
    return regl.texture({
      data,
      width: data.length / 4,
      height: 1,
      format: "rgba",
      mag: "linear",
      min: "linear"
    });
  };
  var makePass = (outputs, ready, setSize, execute) => ({
    outputs: outputs ?? {},
    ready: ready ?? Promise.resolve(),
    setSize: setSize ?? (() => {
    }),
    execute: execute ?? (() => {
    })
  });
  var makePipeline = (context2, steps) => steps.filter((f) => f != null).reduce((pipeline, f, i) => [...pipeline, f(context2, i == 0 ? null : pipeline[i - 1].outputs)], []);

  // contents/matrix/js/regl/rainPass.js
  var extractEntries = (src, keys) => Object.fromEntries(Array.from(Object.entries(src)).filter(([key]) => keys.includes(key)));
  var rippleTypes = {
    box: 0,
    circle: 1
  };
  var makeComputeDoubleBuffer = (regl, height, width) => makeDoubleBuffer(regl, {
    width,
    height,
    wrapS: "clamp",
    wrapT: "clamp",
    min: "nearest",
    mag: "nearest",
    type: "half float"
  });
  var numVerticesPerQuad = 2 * 3;
  var tlVert = [0, 0];
  var trVert = [0, 1];
  var blVert = [1, 0];
  var brVert = [1, 1];
  var quadVertices = [tlVert, trVert, brVert, tlVert, brVert, blVert];
  var rainPass_default = ({ regl, config, lkg }) => {
    const { mat2, mat4, vec2, vec3 } = glMatrix;
    const volumetric = config.volumetric;
    const density = volumetric && config.effect !== "none" ? config.density : 1;
    const [numRows, numColumns] = [config.numColumns, Math.floor(config.numColumns * density)];
    const [numQuadRows, numQuadColumns] = volumetric ? [numRows, numColumns] : [1, 1];
    const numQuads = numQuadRows * numQuadColumns;
    const quadSize = [1 / numQuadColumns, 1 / numQuadRows];
    const rippleType = config.rippleTypeName in rippleTypes ? rippleTypes[config.rippleTypeName] : -1;
    const slantVec = [Math.cos(config.slant), Math.sin(config.slant)];
    const slantScale = 1 / (Math.abs(Math.sin(2 * config.slant)) * (Math.sqrt(2) - 1) + 1);
    const showDebugView = config.effect === "none";
    const glyphTransform = mat2.fromScaling(mat2.create(), vec2.fromValues(config.glyphFlip ? -1 : 1, 1));
    mat2.rotate(glyphTransform, glyphTransform, config.glyphRotation * Math.PI / 180);
    const commonUniforms = {
      ...extractEntries(config, ["animationSpeed", "glyphHeightToWidth", "glyphSequenceLength", "glyphTextureGridSize"]),
      numColumns,
      numRows,
      showDebugView
    };
    const introDoubleBuffer = makeComputeDoubleBuffer(regl, 1, numColumns);
    const rainPassIntro = loadText("shaders/glsl/rainPass.intro.frag.glsl");
    const introUniforms = {
      ...commonUniforms,
      ...extractEntries(config, ["fallSpeed", "skipIntro"])
    };
    const intro = regl({
      frag: regl.prop("frag"),
      uniforms: {
        ...introUniforms,
        previousIntroState: introDoubleBuffer.back
      },
      framebuffer: introDoubleBuffer.front
    });
    const raindropDoubleBuffer = makeComputeDoubleBuffer(regl, numRows, numColumns);
    const rainPassRaindrop = loadText("shaders/glsl/rainPass.raindrop.frag.glsl");
    const raindropUniforms = {
      ...commonUniforms,
      ...extractEntries(config, ["brightnessDecay", "fallSpeed", "raindropLength", "loops", "skipIntro"])
    };
    const raindrop = regl({
      frag: regl.prop("frag"),
      uniforms: {
        ...raindropUniforms,
        introState: introDoubleBuffer.front,
        previousRaindropState: raindropDoubleBuffer.back
      },
      framebuffer: raindropDoubleBuffer.front
    });
    const symbolDoubleBuffer = makeComputeDoubleBuffer(regl, numRows, numColumns);
    const rainPassSymbol = loadText("shaders/glsl/rainPass.symbol.frag.glsl");
    const symbolUniforms = {
      ...commonUniforms,
      ...extractEntries(config, ["cycleSpeed", "cycleFrameSkip", "loops"])
    };
    const symbol = regl({
      frag: regl.prop("frag"),
      uniforms: {
        ...symbolUniforms,
        raindropState: raindropDoubleBuffer.front,
        previousSymbolState: symbolDoubleBuffer.back
      },
      framebuffer: symbolDoubleBuffer.front
    });
    const effectDoubleBuffer = makeComputeDoubleBuffer(regl, numRows, numColumns);
    const rainPassEffect = loadText("shaders/glsl/rainPass.effect.frag.glsl");
    const effectUniforms = {
      ...commonUniforms,
      ...extractEntries(config, ["hasThunder", "rippleScale", "rippleSpeed", "rippleThickness", "loops"]),
      rippleType
    };
    const effect = regl({
      frag: regl.prop("frag"),
      uniforms: {
        ...effectUniforms,
        raindropState: raindropDoubleBuffer.front,
        previousEffectState: effectDoubleBuffer.back
      },
      framebuffer: effectDoubleBuffer.front
    });
    const quadPositions = Array(numQuadRows).fill().map(
      (_, y) => Array(numQuadColumns).fill().map((_2, x) => Array(numVerticesPerQuad).fill([x, y]))
    );
    const glyphMSDF = loadImage(regl, config.glyphMSDFURL);
    const glintMSDF = loadImage(regl, config.glintMSDFURL);
    const baseTexture = loadImage(regl, config.baseTextureURL, true);
    const glintTexture = loadImage(regl, config.glintTextureURL, true);
    const rainPassVert = loadText("shaders/glsl/rainPass.vert.glsl");
    const rainPassFrag = loadText("shaders/glsl/rainPass.frag.glsl");
    const output = makePassFBO(regl, config.useHalfFloat);
    const renderUniforms = {
      ...commonUniforms,
      ...extractEntries(config, [
        // vertex
        "forwardSpeed",
        "glyphVerticalSpacing",
        // fragment
        "baseBrightness",
        "baseContrast",
        "glintBrightness",
        "glintContrast",
        "hasBaseTexture",
        "hasGlintTexture",
        "brightnessThreshold",
        "brightnessOverride",
        "isolateCursor",
        "isolateGlint",
        "glyphEdgeCrop",
        "isPolar"
      ]),
      glyphTransform,
      density,
      numQuadColumns,
      numQuadRows,
      quadSize,
      slantScale,
      slantVec,
      volumetric
    };
    const render = regl({
      blend: {
        enable: true,
        func: {
          src: "one",
          dst: "one"
        }
      },
      vert: regl.prop("vert"),
      frag: regl.prop("frag"),
      uniforms: {
        ...renderUniforms,
        raindropState: raindropDoubleBuffer.front,
        symbolState: symbolDoubleBuffer.front,
        effectState: effectDoubleBuffer.front,
        glyphMSDF: glyphMSDF.texture,
        glintMSDF: glintMSDF.texture,
        baseTexture: baseTexture.texture,
        glintTexture: glintTexture.texture,
        msdfPxRange: 4,
        glyphMSDFSize: () => [glyphMSDF.width(), glyphMSDF.height()],
        glintMSDFSize: () => [glintMSDF.width(), glintMSDF.height()],
        camera: regl.prop("camera"),
        transform: regl.prop("transform"),
        screenSize: regl.prop("screenSize")
      },
      viewport: regl.prop("viewport"),
      attributes: {
        aPosition: new Float32Array(quadPositions.flat(Infinity)),
        aCorner: new Float32Array(Array(numQuads).fill(quadVertices).flat(Infinity))
      },
      count: numQuads * numVerticesPerQuad,
      depth: { enable: false },
      cull: { enable: false },
      framebuffer: output
    });
    const screenSize = [1, 1];
    const transform = mat4.create();
    if (volumetric && config.isometric) {
      mat4.rotateX(transform, transform, Math.PI * 1 / 8);
      mat4.rotateY(transform, transform, Math.PI * 1 / 4);
      mat4.translate(transform, transform, vec3.fromValues(0, 0, -1));
      mat4.scale(transform, transform, vec3.fromValues(1, 1, 2));
    } else if (lkg.enabled) {
      mat4.translate(transform, transform, vec3.fromValues(0, 0, -1.1));
      mat4.scale(transform, transform, vec3.fromValues(1, 1, 1));
      mat4.scale(transform, transform, vec3.fromValues(0.15, 0.15, 0.15));
    } else {
      mat4.translate(transform, transform, vec3.fromValues(0, 0, -1));
    }
    const camera = mat4.create();
    const vantagePoints = [];
    return makePass(
      {
        primary: output
      },
      Promise.all([
        glyphMSDF.loaded,
        glintMSDF.loaded,
        baseTexture.loaded,
        glintTexture.loaded,
        rainPassIntro.loaded,
        rainPassRaindrop.loaded,
        rainPassSymbol.loaded,
        rainPassVert.loaded,
        rainPassFrag.loaded
      ]),
      (w, h) => {
        output.resize(w, h);
        const aspectRatio2 = w / h;
        const [numTileColumns, numTileRows] = [lkg.tileX, lkg.tileY];
        const numVantagePoints = numTileRows * numTileColumns;
        const tileWidth = Math.floor(w / numTileColumns);
        const tileHeight = Math.floor(h / numTileRows);
        vantagePoints.length = 0;
        for (let row = 0; row < numTileRows; row++) {
          for (let column = 0; column < numTileColumns; column++) {
            const index2 = column + row * numTileColumns;
            const camera2 = mat4.create();
            if (volumetric && config.isometric) {
              if (aspectRatio2 > 1) {
                mat4.ortho(camera2, -1.5 * aspectRatio2, 1.5 * aspectRatio2, -1.5, 1.5, -1e3, 1e3);
              } else {
                mat4.ortho(camera2, -1.5, 1.5, -1.5 / aspectRatio2, 1.5 / aspectRatio2, -1e3, 1e3);
              }
            } else if (lkg.enabled) {
              mat4.perspective(camera2, Math.PI / 180 * lkg.fov, lkg.quiltAspect, 1e-4, 1e3);
              const distanceToTarget = -1;
              let vantagePointAngle = Math.PI / 180 * lkg.viewCone * (index2 / (numVantagePoints - 1) - 0.5);
              if (isNaN(vantagePointAngle)) {
                vantagePointAngle = 0;
              }
              const xOffset = distanceToTarget * Math.tan(vantagePointAngle);
              mat4.translate(camera2, camera2, vec3.fromValues(xOffset, 0, 0));
              camera2[8] = -xOffset / (distanceToTarget * Math.tan(Math.PI / 180 * 0.5 * lkg.fov) * lkg.quiltAspect);
            } else {
              mat4.perspective(camera2, Math.PI / 180 * 90, aspectRatio2, 1e-4, 1e3);
            }
            const viewport = {
              x: column * tileWidth,
              y: row * tileHeight,
              width: tileWidth,
              height: tileHeight
            };
            vantagePoints.push({ camera: camera2, viewport });
          }
        }
        [screenSize[0], screenSize[1]] = aspectRatio2 > 1 ? [1, aspectRatio2] : [1 / aspectRatio2, 1];
      },
      (shouldRender) => {
        intro({ frag: rainPassIntro.text() });
        raindrop({ frag: rainPassRaindrop.text() });
        symbol({ frag: rainPassSymbol.text() });
        effect({ frag: rainPassEffect.text() });
        if (shouldRender) {
          regl.clear({
            depth: 1,
            color: [0, 0, 0, 1],
            framebuffer: output
          });
          for (const vantagePoint of vantagePoints) {
            render({ ...vantagePoint, transform, screenSize, vert: rainPassVert.text(), frag: rainPassFrag.text() });
          }
        }
      }
    );
  };

  // contents/matrix/js/regl/bloomPass.js
  var pyramidHeight = 5;
  var makePyramid = (regl, height, halfFloat) => Array(height).fill().map((_) => makePassFBO(regl, halfFloat));
  var resizePyramid = (pyramid, vw, vh, scale) => pyramid.forEach((fbo, index2) => fbo.resize(Math.floor(vw * scale / 2 ** index2), Math.floor(vh * scale / 2 ** index2)));
  var bloomPass_default = ({ regl, config }, inputs) => {
    const { bloomStrength, bloomSize, highPassThreshold } = config;
    const enabled = bloomSize > 0 && bloomStrength > 0;
    if (!enabled) {
      return makePass({
        primary: inputs.primary,
        bloom: makePassFBO(regl)
      });
    }
    const highPassPyramid = makePyramid(regl, pyramidHeight, config.useHalfFloat);
    const hBlurPyramid = makePyramid(regl, pyramidHeight, config.useHalfFloat);
    const vBlurPyramid = makePyramid(regl, pyramidHeight, config.useHalfFloat);
    const output = makePassFBO(regl, config.useHalfFloat);
    const highPassFrag = loadText("shaders/glsl/bloomPass.highPass.frag.glsl");
    const highPass = regl({
      frag: regl.prop("frag"),
      uniforms: {
        highPassThreshold,
        tex: regl.prop("tex")
      },
      framebuffer: regl.prop("fbo")
    });
    const blurFrag = loadText("shaders/glsl/bloomPass.blur.frag.glsl");
    const blur = regl({
      frag: regl.prop("frag"),
      uniforms: {
        tex: regl.prop("tex"),
        direction: regl.prop("direction"),
        height: regl.context("viewportWidth"),
        width: regl.context("viewportHeight")
      },
      framebuffer: regl.prop("fbo")
    });
    const combineFrag = loadText("shaders/glsl/bloomPass.combine.frag.glsl");
    const combine = regl({
      frag: regl.prop("frag"),
      uniforms: {
        bloomStrength,
        ...Object.fromEntries(vBlurPyramid.map((fbo, index2) => [`pyr_${index2}`, fbo]))
      },
      framebuffer: output
    });
    return makePass(
      {
        primary: inputs.primary,
        bloom: output
      },
      Promise.all([highPassFrag.loaded, blurFrag.loaded]),
      (w, h) => {
        resizePyramid(highPassPyramid, w, h, bloomSize);
        resizePyramid(hBlurPyramid, w, h, bloomSize);
        resizePyramid(vBlurPyramid, w, h, bloomSize);
        output.resize(w, h);
      },
      (shouldRender) => {
        if (!shouldRender) {
          return;
        }
        for (let i = 0; i < pyramidHeight; i++) {
          const highPassFBO = highPassPyramid[i];
          const hBlurFBO = hBlurPyramid[i];
          const vBlurFBO = vBlurPyramid[i];
          highPass({ fbo: highPassFBO, frag: highPassFrag.text(), tex: i === 0 ? inputs.primary : highPassPyramid[i - 1] });
          blur({ fbo: hBlurFBO, frag: blurFrag.text(), tex: highPassFBO, direction: [1, 0] });
          blur({ fbo: vBlurFBO, frag: blurFrag.text(), tex: hBlurFBO, direction: [0, 1] });
        }
        combine({ frag: combineFrag.text() });
      }
    );
  };

  // contents/matrix/js/colorToRGB.js
  var colorToRGB_default = ({ space, values }) => {
    if (space === "rgb") {
      return values;
    }
    const [hue, saturation, lightness] = values;
    const a = saturation * Math.min(lightness, 1 - lightness);
    const f = (n) => {
      const k = (n + hue * 12) % 12;
      return lightness - a * Math.max(-1, Math.min(k - 3, 9 - k, 1));
    };
    return [f(0), f(8), f(4)];
  };

  // contents/matrix/js/regl/palettePass.js
  var makePalette = (regl, entries) => {
    const PALETTE_SIZE = 2048;
    const paletteColors = Array(PALETTE_SIZE);
    const sortedEntries = entries.slice().sort((e1, e2) => e1.at - e2.at).map((entry) => ({
      rgb: colorToRGB_default(entry.color),
      arrayIndex: Math.floor(Math.max(Math.min(1, entry.at), 0) * (PALETTE_SIZE - 1))
    }));
    sortedEntries.unshift({ rgb: sortedEntries[0].rgb, arrayIndex: 0 });
    sortedEntries.push({
      rgb: sortedEntries[sortedEntries.length - 1].rgb,
      arrayIndex: PALETTE_SIZE - 1
    });
    sortedEntries.forEach((entry, index2) => {
      paletteColors[entry.arrayIndex] = entry.rgb.slice();
      if (index2 + 1 < sortedEntries.length) {
        const nextEntry = sortedEntries[index2 + 1];
        const diff = nextEntry.arrayIndex - entry.arrayIndex;
        for (let i = 0; i < diff; i++) {
          const ratio = i / diff;
          paletteColors[entry.arrayIndex + i] = [
            entry.rgb[0] * (1 - ratio) + nextEntry.rgb[0] * ratio,
            entry.rgb[1] * (1 - ratio) + nextEntry.rgb[1] * ratio,
            entry.rgb[2] * (1 - ratio) + nextEntry.rgb[2] * ratio
          ];
        }
      }
    });
    return make1DTexture(
      regl,
      paletteColors.map((rgb) => [...rgb, 1])
    );
  };
  var palettePass_default = ({ regl, config }, inputs) => {
    const output = makePassFBO(regl, config.useHalfFloat);
    const paletteTex = makePalette(regl, config.palette);
    const { backgroundColor, cursorColor, glintColor, cursorIntensity, glintIntensity, ditherMagnitude } = config;
    const palettePassFrag = loadText("shaders/glsl/palettePass.frag.glsl");
    const render = regl({
      frag: regl.prop("frag"),
      uniforms: {
        backgroundColor: colorToRGB_default(backgroundColor),
        cursorColor: colorToRGB_default(cursorColor),
        glintColor: colorToRGB_default(glintColor),
        cursorIntensity,
        glintIntensity,
        ditherMagnitude,
        tex: inputs.primary,
        bloomTex: inputs.bloom,
        paletteTex
      },
      framebuffer: output
    });
    return makePass(
      {
        primary: output
      },
      palettePassFrag.loaded,
      (w, h) => output.resize(w, h),
      (shouldRender) => {
        if (shouldRender) {
          render({ frag: palettePassFrag.text() });
        }
      }
    );
  };

  // contents/matrix/js/regl/stripePass.js
  var transPrideStripeColors = [
    { space: "rgb", values: [0.36, 0.81, 0.98] },
    { space: "rgb", values: [0.96, 0.66, 0.72] },
    { space: "rgb", values: [1, 1, 1] },
    { space: "rgb", values: [0.96, 0.66, 0.72] },
    { space: "rgb", values: [0.36, 0.81, 0.98] }
  ].map((color) => Array(3).fill(color)).flat();
  var prideStripeColors = [
    { space: "rgb", values: [0.89, 0.01, 0.01] },
    { space: "rgb", values: [1, 0.55, 0] },
    { space: "rgb", values: [1, 0.93, 0] },
    { space: "rgb", values: [0, 0.5, 0.15] },
    { space: "rgb", values: [0, 0.3, 1] },
    { space: "rgb", values: [0.46, 0.03, 0.53] }
  ].map((color) => Array(2).fill(color)).flat();
  var stripePass_default = ({ regl, config }, inputs) => {
    const output = makePassFBO(regl, config.useHalfFloat);
    const { backgroundColor, cursorColor, glintColor, cursorIntensity, glintIntensity, ditherMagnitude } = config;
    const stripeColors = "stripeColors" in config ? config.stripeColors : config.effect === "pride" ? prideStripeColors : transPrideStripeColors;
    const stripeTex = make1DTexture(
      regl,
      stripeColors.map((color) => [...colorToRGB_default(color), 1])
    );
    const stripePassFrag = loadText("shaders/glsl/stripePass.frag.glsl");
    const render = regl({
      frag: regl.prop("frag"),
      uniforms: {
        backgroundColor: colorToRGB_default(backgroundColor),
        cursorColor: colorToRGB_default(cursorColor),
        glintColor: colorToRGB_default(glintColor),
        cursorIntensity,
        glintIntensity,
        ditherMagnitude,
        tex: inputs.primary,
        bloomTex: inputs.bloom,
        stripeTex
      },
      framebuffer: output
    });
    return makePass(
      {
        primary: output
      },
      stripePassFrag.loaded,
      (w, h) => output.resize(w, h),
      (shouldRender) => {
        if (shouldRender) {
          render({ frag: stripePassFrag.text() });
        }
      }
    );
  };

  // contents/matrix/js/regl/imagePass.js
  var defaultBGURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Flammarion_Colored.jpg/917px-Flammarion_Colored.jpg";
  var imagePass_default = ({ regl, config }, inputs) => {
    const output = makePassFBO(regl, config.useHalfFloat);
    const bgURL = "bgURL" in config ? config.bgURL : defaultBGURL;
    const background = loadImage(regl, bgURL);
    const imagePassFrag = loadText("shaders/glsl/imagePass.frag.glsl");
    const render = regl({
      frag: regl.prop("frag"),
      uniforms: {
        backgroundTex: background.texture,
        tex: inputs.primary,
        bloomTex: inputs.bloom
      },
      framebuffer: output
    });
    return makePass(
      {
        primary: output
      },
      Promise.all([background.loaded, imagePassFrag.loaded]),
      (w, h) => output.resize(w, h),
      (shouldRender) => {
        if (shouldRender) {
          render({ frag: imagePassFrag.text() });
        }
      }
    );
  };

  // contents/matrix/js/regl/quiltPass.js
  var quiltPass_default = ({ regl, config, lkg }, inputs) => {
    if (!lkg.enabled) {
      return makePass({
        primary: inputs.primary
      });
    }
    const output = makePassFBO(regl, config.useHalfFloat);
    const quiltPassFrag = loadText("shaders/glsl/quiltPass.frag.glsl");
    const render = regl({
      frag: regl.prop("frag"),
      uniforms: {
        quiltTexture: inputs.primary,
        ...lkg
      },
      framebuffer: output
    });
    return makePass(
      {
        primary: output
      },
      Promise.all([quiltPassFrag.loaded]),
      (w, h) => output.resize(w, h),
      (shouldRender) => {
        if (shouldRender) {
          render({ frag: quiltPassFrag.text() });
        }
      }
    );
  };

  // contents/matrix/js/regl/mirrorPass.js
  var start;
  var numClicks = 5;
  var clicks = Array(numClicks).fill([0, 0, -Infinity]).flat();
  var aspectRatio = 1;
  var index = 0;
  window.onclick = (e) => {
    clicks[index * 3 + 0] = 0 + e.clientX / e.srcElement.clientWidth;
    clicks[index * 3 + 1] = 1 - e.clientY / e.srcElement.clientHeight;
    clicks[index * 3 + 2] = (Date.now() - start) / 1e3;
    index = (index + 1) % numClicks;
  };
  var mirrorPass_default = ({ regl, config, cameraTex, cameraAspectRatio: cameraAspectRatio2 }, inputs) => {
    const output = makePassFBO(regl, config.useHalfFloat);
    const mirrorPassFrag = loadText("shaders/glsl/mirrorPass.frag.glsl");
    const render = regl({
      frag: regl.prop("frag"),
      uniforms: {
        time: regl.context("time"),
        tex: inputs.primary,
        bloomTex: inputs.bloom,
        cameraTex,
        clicks: () => clicks,
        aspectRatio: () => aspectRatio,
        cameraAspectRatio: cameraAspectRatio2
      },
      framebuffer: output
    });
    start = Date.now();
    return makePass(
      {
        primary: output
      },
      Promise.all([mirrorPassFrag.loaded]),
      (w, h) => {
        output.resize(w, h);
        aspectRatio = w / h;
      },
      (shouldRender) => {
        if (shouldRender) {
          render({ frag: mirrorPassFrag.text() });
        }
      }
    );
  };

  // contents/matrix/js/camera.js
  var video = document.createElement("video");
  var cameraCanvas = document.createElement("canvas");
  cameraCanvas.width = 1;
  cameraCanvas.height = 1;
  var context = cameraCanvas.getContext("2d");
  var cameraAspectRatio = 1;
  var cameraSize = [1, 1];
  var drawToCanvas = () => {
    requestAnimationFrame(drawToCanvas);
    context.drawImage(video, 0, 0);
  };
  var setupCamera = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { min: 800, ideal: 1280 },
          frameRate: { ideal: 60 }
        },
        audio: false
      });
      const videoTrack = stream.getVideoTracks()[0];
      const { width, height } = videoTrack.getSettings();
      video.width = width;
      video.height = height;
      cameraCanvas.width = width;
      cameraCanvas.height = height;
      cameraAspectRatio = width / height;
      cameraSize[0] = width;
      cameraSize[1] = height;
      video.srcObject = stream;
      video.play();
      drawToCanvas();
    } catch (e) {
      console.warn(`Camera not initialized: ${e}`);
    }
  };

  // contents/matrix/js/regl/lkgHelper.js
  var recordedDevice = {
    buttons: [0, 0, 0, 0],
    calibration: {
      DPI: { value: 324 },
      center: { value: 0.15018756687641144 },
      configVersion: "3.0",
      flipImageX: { value: 0 },
      flipImageY: { value: 0 },
      flipSubp: { value: 0 },
      fringe: { value: 0 },
      invView: { value: 1 },
      pitch: { value: 52.58013153076172 },
      screenH: { value: 2048 },
      screenW: { value: 1536 },
      slope: { value: -7.145165920257568 },
      verticalAngle: { value: 0 },
      viewCone: { value: 40 }
    },
    defaultQuilt: {
      quiltAspect: 0.75,
      quiltX: 3840,
      quiltY: 3840,
      tileX: 8,
      tileY: 6
    },
    hardwareVersion: "portrait",
    hwid: "LKG-P11063",
    index: 0,
    joystickIndex: -1,
    state: "ok",
    unityIndex: 1,
    windowCoords: [1440, 900]
  };
  var interpretDevice = (device) => {
    if (device == null) {
      return { enabled: false, tileX: 1, tileY: 1 };
    }
    const fov = 15;
    const calibration = Object.fromEntries(
      Object.entries(device.calibration).map(([key, value]) => [key, value.value]).filter(([key, value]) => value != null)
    );
    const screenInches = calibration.screenW / calibration.DPI;
    const pitch = calibration.pitch * screenInches * Math.cos(Math.atan(1 / calibration.slope));
    const tilt = calibration.screenH / (calibration.screenW * calibration.slope) * -(calibration.flipImageX * 2 - 1);
    const subp = 1 / (calibration.screenW * 3);
    const defaultQuilt = device.defaultQuilt;
    const quiltViewPortion = [
      Math.floor(defaultQuilt.quiltX / defaultQuilt.tileX) * defaultQuilt.tileX / defaultQuilt.quiltX,
      Math.floor(defaultQuilt.quiltY / defaultQuilt.tileY) * defaultQuilt.tileY / defaultQuilt.quiltY
    ];
    return {
      ...defaultQuilt,
      ...calibration,
      pitch,
      tilt,
      subp,
      quiltViewPortion,
      fov,
      enabled: true
    };
  };
  var lkgHelper_default = async (useHoloplay = false, useRecordedDevice = false) => {
    if (!useHoloplay) {
      return interpretDevice(null);
    }
    const HoloPlayCore = await Promise.resolve().then(() => (init_holoplaycore_module(), holoplaycore_module_exports));
    const device = await new Promise(
      (resolve, reject) => new HoloPlayCore.Client(
        (data) => resolve(data.devices?.[0]),
        (error) => resolve(null)
      )
    );
    if (device == null && useRecordedDevice) {
      return interpretDevice(recordedDevice);
    }
    return interpretDevice(device);
  };

  // contents/matrix/js/regl/main.js
  var effects = {
    none: null,
    plain: palettePass_default,
    palette: palettePass_default,
    customStripes: stripePass_default,
    stripes: stripePass_default,
    pride: stripePass_default,
    transPride: stripePass_default,
    trans: stripePass_default,
    image: imagePass_default,
    mirror: mirrorPass_default
  };
  var dimensions = { width: 1, height: 1 };
  var loadJS = (src) => new Promise((resolve, reject) => {
    const tag = document.createElement("script");
    tag.onload = resolve;
    tag.onerror = reject;
    tag.src = src;
    document.body.appendChild(tag);
  });
  var main_default = async (canvas2, config) => {
    await Promise.all([loadJS("lib/regl.min.js"), loadJS("lib/gl-matrix.js")]);
    const resize = () => {
      const devicePixelRatio = window.devicePixelRatio ?? 1;
      canvas2.width = Math.ceil(canvas2.clientWidth * devicePixelRatio * config.resolution);
      canvas2.height = Math.ceil(canvas2.clientHeight * devicePixelRatio * config.resolution);
    };
    window.onresize = resize;
    if (document.fullscreenEnabled || document.webkitFullscreenEnabled) {
      window.ondblclick = () => {
        if (document.fullscreenElement == null) {
          if (canvas2.webkitRequestFullscreen != null) {
            canvas2.webkitRequestFullscreen();
          } else {
            canvas2.requestFullscreen();
          }
        } else {
          document.exitFullscreen();
        }
      };
    }
    resize();
    if (config.useCamera) {
      await setupCamera();
    }
    const gl = canvas2.getContext("webgl", {
      antialias: false,
      depth: false,
      stencil: false,
      alpha: false,
      preserveDrawingBuffer: false
    });
    const extensions = ["OES_texture_half_float", "OES_texture_half_float_linear"];
    const optionalExtensions = ["EXT_color_buffer_half_float", "WEBGL_color_buffer_float", "OES_standard_derivatives"];
    switch (config.testFix) {
      case "fwidth_10_1_2022_A":
        extensions.push("OES_standard_derivatives");
        break;
      case "fwidth_10_1_2022_B":
        optionalExtensions.forEach((ext) => extensions.push(ext));
        extensions.length = 0;
        break;
    }
    const regl = createREGL({
      gl,
      pixelRatio: 1,
      extensions,
      optionalExtensions
    });
    const cameraTex = regl.texture(cameraCanvas);
    const lkg = await lkgHelper_default(config.useHoloplay, true);
    const fullScreenQuad = makeFullScreenQuad(regl);
    const effectName = config.effect in effects ? config.effect : "palette";
    const context2 = { regl, config, lkg, cameraTex, cameraAspectRatio };
    const pipeline = makePipeline(context2, [rainPass_default, bloomPass_default, effects[effectName], quiltPass_default]);
    const screenUniforms = { tex: pipeline[pipeline.length - 1].outputs.primary };
    const drawToScreen = regl({ uniforms: screenUniforms });
    await Promise.all(pipeline.map((step) => step.ready));
    const targetFrameTimeMilliseconds = 1e3 / config.fps;
    let last = NaN;
    const tick = regl.frame(({ viewportWidth, viewportHeight }) => {
      if (config.once) {
        tick.cancel();
      }
      const now = regl.now() * 1e3;
      if (isNaN(last)) {
        last = now;
      }
      const shouldRender = config.fps >= 60 || now - last >= targetFrameTimeMilliseconds || config.once == true;
      if (shouldRender) {
        while (now - targetFrameTimeMilliseconds > last) {
          last += targetFrameTimeMilliseconds;
        }
      }
      if (config.useCamera) {
        cameraTex(cameraCanvas);
      }
      if (dimensions.width !== viewportWidth || dimensions.height !== viewportHeight) {
        dimensions.width = viewportWidth;
        dimensions.height = viewportHeight;
        for (const step of pipeline) {
          step.setSize(viewportWidth, viewportHeight);
        }
      }
      fullScreenQuad(() => {
        for (const step of pipeline) {
          step.execute(shouldRender);
        }
        drawToScreen();
      });
    });
  };

  // contents/matrix/js/main.js
  var canvas = document.createElement("canvas");
  document.body.appendChild(canvas);
  document.addEventListener("touchmove", (e) => e.preventDefault(), {
    passive: false
  });
  let globalConfig = null;
  window.updateConfig = (newConfig) => {
    if (globalConfig) {
      Object.assign(globalConfig, newConfig);
    } else {
      window.pendingConfig = newConfig;
    }
  };
  document.body.onload = async () => {
    const urlParams = new URLSearchParams(window.location.search || (window.location.hash.substring(1) ? "?" + window.location.hash.substring(1) : ""));
    const config = config_default(Object.fromEntries(urlParams.entries()));
    globalConfig = config;
    if (window.pendingConfig) {
      Object.assign(globalConfig, window.pendingConfig);
    }
    await main_default(canvas, config);
  };
})();
/**
 * This files defines the HoloPlayClient class and Message class.
 *
 * Copyright (c) [2019] [Looking Glass Factory]
 *
 * @link    https://lookingglassfactory.com/
 * @file    This files defines the HoloPlayClient class and Message class.
 * @author  Looking Glass Factory.
 * @version 0.0.8
 * @license SEE LICENSE IN LICENSE.md
 */
