const fs = require('fs');

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

async function ensureChrome({ cacheDir, onProgress }) {
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

	if (fs.existsSync(executablePath)) {
		return { executablePath, buildId, alreadyInstalled: true };
	}

	try {
		const installed = await install({
			browser: Browser.CHROME,
			buildId,
			cacheDir,
			downloadProgressCallback: (downloaded, total) => {
				if (typeof onProgress === 'function') {
					onProgress({ downloaded, total });
				}
			},
		});
		return {
			executablePath: installed.executablePath,
			buildId,
			alreadyInstalled: false,
		};
	} catch (err) {
		throw friendlyError(err);
	}
}

module.exports = { ensureChrome };
