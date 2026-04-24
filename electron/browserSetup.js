const fs = require('fs');
const path = require('path');

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
	throw new Error('Não foi possível resolver a versão do Chrome a partir do puppeteer.');
}

function friendlyError(err) {
	const code = err && err.code;
	if (code === 'ENOTFOUND' || code === 'ECONNREFUSED' || code === 'ETIMEDOUT' || code === 'EAI_AGAIN') {
		const e = new Error('Sem conexão para baixar o navegador. Conecte-se à internet e tente novamente.');
		e.cause = err;
		return e;
	}
	return err;
}

function wipeCorruptFolder(browserFolder) {
	try {
		fs.rmSync(browserFolder, { recursive: true, force: true });
	} catch {}
}

async function ensureChrome({ cacheDir, onProgress, onExtracting }) {
	const {
		Browser,
		install,
		computeExecutablePath,
		detectBrowserPlatform,
	} = require('@puppeteer/browsers');
	const buildId = loadRevisions().chrome;
	const platform = detectBrowserPlatform();
	if (!platform) {
		throw new Error('Plataforma não suportada para download do navegador.');
	}

	fs.mkdirSync(cacheDir, { recursive: true });

	const executablePath = computeExecutablePath({
		browser: Browser.CHROME,
		buildId,
		cacheDir,
	});

	// executablePath is `<cacheDir>/chrome/<platform>-<buildId>/chrome-<platform>/chrome.exe`.
	// The "browser folder" (win64-<buildId>) is two levels up.
	const browserFolder = path.dirname(path.dirname(executablePath));

	if (fs.existsSync(executablePath)) {
		return { executablePath, buildId, alreadyInstalled: true };
	}

	// Pre-install cleanup: a prior install left the folder but no executable
	// (extraction was interrupted or never finished). `install()` would otherwise
	// throw "browser folder exists but the executable is missing" immediately.
	if (fs.existsSync(browserFolder)) {
		wipeCorruptFolder(browserFolder);
	}

	let extractingFired = false;
	const progressCallback = (downloaded, total) => {
		if (typeof onProgress === 'function') {
			onProgress({ downloaded, total });
		}
		if (!extractingFired && total > 0 && downloaded >= total && typeof onExtracting === 'function') {
			extractingFired = true;
			onExtracting();
		}
	};

	const doInstall = () => install({
		browser: Browser.CHROME,
		buildId,
		cacheDir,
		downloadProgressCallback: progressCallback,
	});

	try {
		const installed = await doInstall();
		return {
			executablePath: installed.executablePath,
			buildId,
			alreadyInstalled: false,
		};
	} catch (err) {
		if (err && typeof err.message === 'string' && err.message.includes('exists but the executable')) {
			wipeCorruptFolder(browserFolder);
			extractingFired = false;
			const installed = await doInstall().catch((err2) => { throw friendlyError(err2); });
			return {
				executablePath: installed.executablePath,
				buildId,
				alreadyInstalled: false,
			};
		}
		throw friendlyError(err);
	}
}

module.exports = { ensureChrome };
