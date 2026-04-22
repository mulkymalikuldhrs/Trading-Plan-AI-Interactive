const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('http://localhost:8080');
  await page.waitForTimeout(10000); // Wait for the app to load
  await page.screenshot({ path: 'frontend_verification.png', fullPage: true });
  await browser.close();
})();
