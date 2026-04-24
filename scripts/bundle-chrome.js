// Pre-downloads Chrome into ./chrome-cache so electron-builder can ship it
// as extraResources. Runs automatically before `npm run dist` / `npm run release`.
// Idempotent: skips the download when the expected binary is already on disk.

const fs = require('fs');
const path = require('path');

const CACHE_DIR = path.resolve(__dirname, '..', 'chrome-cache');

function loadRevisions() {
	const candidates = [
		'puppeteer-core/lib/cjs/puppeteer/revisions.js',
		'puppeteer/lib/cjs/puppeteer/revisions.js',
	];
	for (const id of candidates) {
		try {
			const mod = require(id);
			if (mod && mod.PUPPETEER_REVISIONS) return mod.PUPPETEER_REVISIONS;
		} catch {}
	}
	throw new Error('Cannot resolve Chrome build id from puppeteer.');
}

async function main() {
	const { Browser, install, computeExecutablePath, detectBrowserPlatform } =
		require('@puppeteer/browsers');
	const buildId = loadRevisions().chrome;
	const platform = detectBrowserPlatform();
	if (!platform) throw new Error('Unsupported platform for Chrome bundling.');

	fs.mkdirSync(CACHE_DIR, { recursive: true });

	const executablePath = computeExecutablePath({
		browser: Browser.CHROME,
		buildId,
		cacheDir: CACHE_DIR,
	});

	if (fs.existsSync(executablePath)) {
		console.log(`[bundle-chrome] already present: ${executablePath}`);
		return;
	}

	const browserFolder = path.dirname(path.dirname(executablePath));
	if (fs.existsSync(browserFolder)) {
		console.log(`[bundle-chrome] wiping partial folder: ${browserFolder}`);
		fs.rmSync(browserFolder, { recursive: true, force: true });
	}

	console.log(`[bundle-chrome] downloading chrome ${buildId} for ${platform}…`);
	let lastPct = -1;
	await install({
		browser: Browser.CHROME,
		buildId,
		cacheDir: CACHE_DIR,
		downloadProgressCallback: (downloaded, total) => {
			if (!total) return;
			const pct = Math.floor((downloaded / total) * 100);
			if (pct !== lastPct && pct % 5 === 0) {
				lastPct = pct;
				console.log(`[bundle-chrome] ${pct}% (${(downloaded / 1024 / 1024).toFixed(1)} MB)`);
			}
		},
	});
	console.log(`[bundle-chrome] done: ${executablePath}`);
}

main().catch((err) => {
	console.error('[bundle-chrome] failed:', err);
	process.exit(1);
});
