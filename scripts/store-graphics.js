// Setzt Store-Screenshots (1080 × 1920) und das Banner (1024 × 500) aus den Rohbildern zusammen.
// Voraussetzung: Rohbilder aus app/tool/store_screenshots_test.dart, Node mit Playwright
// (PLAYWRIGHT_MODULE: Pfad zum Paket, CHROMIUM_PATH: optional eigener Browser).
const path = require('path');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const fs = require('fs');
const root = path.join(__dirname, '..');
const raw = path.join(root, 'app/build/store/raw');
const FONT = "@font-face{font-family:Manrope;font-weight:200 800;src:url(data:font/ttf;base64," +
  fs.readFileSync(path.join(root, 'app/assets/fonts/Manrope-Variable.ttf')).toString('base64') + ") format('truetype')}";
const outDir = path.join(root, 'fastlane/metadata/android/de-DE/images');
const shots = [
  ['1_tagebuch', 'Kalorien & Makros<br>auf einen Blick', 'Ring, Eiweiß, Kohlenhydrate, Fett'],
  ['2_details', 'Zucker, Stärke,<br>Fettqualität', 'Kurz- und langkettige Kohlenhydrate, gesättigte und ungesättigte Fette'],
  ['3_gewicht', 'Dein echter Bedarf –<br>gemessen', 'Nach 14 Tagen aus Essen und Gewichtstrend'],
  ['4_menge', 'Scannen, Menge<br>wählen, fertig', 'Barcode-Scanner mit Open Food Facts'],
  ['5_dunkel', 'Hell oder dunkel', 'Hier: Schwarz mit Gold'],
  ['6_farben', 'Deine Farbwelt', 'Waldgrün, Dunkelrot, Oliv, Schwarz, Blau, Weiß'],
];
(async () => {
  const b = await chromium.launch(process.env.CHROMIUM_PATH ? { executablePath: process.env.CHROMIUM_PATH } : {});
  const p = await b.newPage({ viewport: { width: 1080, height: 1920 } });
  for (const [i, [file, title, sub]] of shots.entries()) {
    const img = 'data:image/png;base64,' + fs.readFileSync(path.join(raw, `${file}.png`)).toString('base64');
    await p.setContent(`<html><head><style>${FONT}
      body{margin:0;width:1080px;height:1920px;overflow:hidden;font-family:Manrope;
        background:radial-gradient(120% 70% at 50% 0%,#2A6A50 0%,#1F4D3A 45%,#14342A 100%)}
      h1{margin:0;padding:110px 70px 0;color:#fff;font-size:76px;line-height:1.08;font-weight:800;letter-spacing:-1.5px;text-align:center;font-variation-settings:'wght' 800}
      p{margin:26px 90px 0;color:#E6D3A0;font-size:34px;line-height:1.3;text-align:center;font-weight:600;font-variation-settings:'wght' 600}
      .phone{position:absolute;left:50%;top:${sub ? 560 : 470}px;transform:translateX(-50%);width:780px;border-radius:56px;overflow:hidden;
        box-shadow:0 30px 80px rgba(0,0,0,.45);border:12px solid #0d0f0e}
      .phone img{display:block;width:100%}
    </style></head><body><h1>${title}</h1><p>${sub}</p><div class="phone"><img src="${img}"></div></body></html>`);
    await p.evaluate(() => document.fonts.ready); await p.waitForTimeout(150);
    await p.screenshot({ path: `${outDir}/phoneScreenshots/${i + 1}.png` });
  }
  const logo = 'data:image/png;base64,' + fs.readFileSync(path.join(root, 'docs/branding/icon-512.png')).toString('base64');
  const g = await b.newPage({ viewport: { width: 1024, height: 500 } });
  await g.setContent(`<html><head><style>${FONT}
    body{margin:0;width:1024px;height:500px;overflow:hidden;font-family:Manrope;display:flex;align-items:center;gap:56px;padding:0 80px;box-sizing:border-box;
      background:radial-gradient(90% 120% at 15% 50%,#2A6A50 0%,#1F4D3A 50%,#14342A 100%)}
    img{width:250px;height:250px;border-radius:58px;box-shadow:0 20px 50px rgba(0,0,0,.35)}
    h1{margin:0;color:#fff;font-size:96px;font-weight:800;letter-spacing:-2px;font-variation-settings:'wght' 800}
    p{margin:14px 0 0;color:#E6D3A0;font-size:32px;line-height:1.3;font-weight:600;font-variation-settings:'wght' 600}
  </style></head><body><img src="${logo}"><div><h1>MuScale</h1><p>Kalorien &amp; Makros für Kraftsport.<br>Ohne Konto. Ohne Werbung.</p></div></body></html>`);
  await g.evaluate(() => document.fonts.ready); await g.waitForTimeout(150);
  await g.screenshot({ path: `${outDir}/featureGraphic.png` });
  await b.close();
})();
