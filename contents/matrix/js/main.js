import makeConfig from "./config.js";
import reglSolution from "./regl/main.js";

const canvas = document.createElement("canvas");
document.body.appendChild(canvas);
document.addEventListener("touchmove", (e) => e.preventDefault(), {
	passive: false,
});

const isRunningSwiftShader = () => {
	const gl = document.createElement("canvas").getContext("webgl");
	if (!gl) return false;
	const debugInfo = gl.getExtension("WEBGL_debug_renderer_info");
	if (!debugInfo) return false;
	const renderer = gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL);
	return renderer.toLowerCase().includes("swiftshader");
};

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
	const config = makeConfig(Object.fromEntries(urlParams.entries()));
	globalConfig = config;

	if (window.pendingConfig) {
		Object.assign(globalConfig, window.pendingConfig);
	}

	await reglSolution(canvas, config);
};
