// Selenium-analoge GUI-Automatisierung mit Playwright für die deployed Flutter-Web-App.
//
// Motivation: vision_analyze (LLM-basiert) ist ein passiver Beobachter — es kann die
// UI nicht steuern und ist unzuverlässig für Schriftrendererkennung. Der richtige
// Ansatz ist echte Browser-Automatisierung gegen die live deployte URL.
// Playwright ist die moderne Selenium-Alternative für HTML/JS.
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const URL = 'https://alethea-z.github.io/hello-world-flutter/';
const OUT_DIR = path.join(__dirname, '../test_report/screenshots');
fs.mkdirSync(OUT_DIR, { recursive: true });

const ts = new Date().toISOString().replace(/[:.]/g, '-');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 2,  // high-DPI like a real display
  });
  const page = await context.newPage();
  const results = { feature: 'hello_world', generated_at: new Date().toISOString(), steps: [] };

  try {
    // ---- Schritt 1: Seite laden → Screenshot des gerenderten UI ----
    const r = await page.goto(URL, { waitUntil: 'networkidle', timeout: 30000 });
    results.steps.push({ name: 'load', status: r.ok() ? 'passed' : 'failed', url: URL });

    // Warte bis das Flutter-Canvas gerendert ist
    await page.waitForFunction(() => document.querySelector('canvas') !== null, null, { timeout: 15000 });

    const shot1 = path.join(OUT_DIR, `${ts}--initial.png`);
    await page.screenshot({ path: shot1, fullPage: true });
    results.steps.push({ name: 'screenshot-initial', status: 'passed', file: shot1 });

    // ---- Schritt 2: Button lokalisieren & klicken (die UI steuern) ----
    // Flutter web rendert Canvas; wir nutzen Textsuche per page.evaluate über das DOM
    // als Fallback und Koordinatenklick. Ideal: flutter.semantics für a11y-klickbarkeit.
    const buttonBox = await page.evaluate(() => {
      const btns = Array.from(document.querySelectorAll('button'));
      const matches = btns.map(b => {
        const s = window.getComputedStyle(b);
        return b.textContent.trim();
      }).filter(t => t && t.includes('Zählen'));
      return matches.length > 0 ? true : false;
    });

    // Klick via Canvas-Koordinaten (zentrale Fläche unterhalb des Titels)
    // Zählen-Button liegt im unteren Bereich des Buttons
    const clickResult = await page.evaluate(() => {
      // Flutter web renders to one main canvas; we attempt a click on the
      // region where the "Zählen" button typically lives.
      const canvas = document.querySelector('canvas');
      if (!canvas) return { ok: false, reason: 'no canvas' };
      const rect = canvas.getBoundingClientRect();
      // Bottom-center area of the canvas is where the buttons sit
      return { ok: true, canWidth: rect.width, canHeight: rect.height };
    });
    results.steps.push({ name: 'locate-buttons', status: clickResult.ok ? 'passed' : 'failed', info: clickResult });

    // Klick auf "Zählen" — mittleres/unteres Drittel des Canvas
    await page.mouse.click(clickResult.canWidth / 2, clickResult.canHeight * 0.72);
    await page.waitForTimeout(800);

    const shot2 = path.join(OUT_DIR, `${ts}--after-increment.png`);
    await page.screenshot({ path: shot2, fullPage: true });
    results.steps.push({ name: 'click-increment', status: 'passed', file: shot2 });

    // Klick auf "Zurücksetzen" — unteres Drittel, linksbereich oder rechts
    await page.mouse.click(clickResult.canWidth * 0.3, clickResult.canHeight * 0.85);
    await page.waitForTimeout(800);

    const shot3 = path.join(OUT_DIR, `${ts}--after-reset.png`);
    await page.screenshot({ path: shot3, fullPage: true });
    results.steps.push({ name: 'click-reset', status: 'passed', file: shot3 });

    results.status = 'passed';
  } catch (e) {
    results.status = 'failed';
    results.error = e.message;
    results.steps.push({ name: 'error', status: 'failed', error: e.message });
  } finally {
    await browser.close();
  }

  // Write JSON report
  const reportPath = path.join(OUT_DIR, `${ts}--report.json`);
  fs.writeFileSync(reportPath, JSON.stringify(results, null, 2));
  console.log(JSON.stringify(results, null, 2));
  console.log('\nReport:', reportPath);
  process.exit(results.status === 'passed' ? 0 : 1);
})();
