const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    recordVideo: { dir: '/home/a.key/projects/a.key/kde/kde-matrix-screensaver/assets/', size: { width: 1280, height: 720 } }
  });
  const page = await context.newPage();
  
  await page.goto('file:///home/a.key/projects/a.key/matrix/matrix/index2.html');
  
  // Wait for the effect to warm up
  await page.waitForTimeout(5000);
  
  // Take a screenshot
  await page.screenshot({ path: '/home/a.key/projects/a.key/kde/kde-matrix-screensaver/assets/webgl_bloom_reference.png' });
  
  // Record a few more seconds for the video
  await page.waitForTimeout(5000);
  
  await context.close();
  await browser.close();
})();
