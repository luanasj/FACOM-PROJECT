const { app, BrowserWindow, ipcMain } = require('electron');
const { autoUpdater } = require('electron-updater');
const { spawn, exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const { ensureChrome } = require('./browserSetup');

const DEV_ROOT = path.resolve(__dirname, '..');
const IS_PACKAGED = app.isPackaged;
const BUNDLED_ASSETS = IS_PACKAGED ? path.join(process.resourcesPath, 'assets') : path.join(DEV_ROOT, 'assets');
const USER_ROOT = IS_PACKAGED ? app.getPath('userData') : DEV_ROOT;

const ASSETS_DIR = path.join(USER_ROOT, 'assets');
const WWEBJS_DIR = path.join(USER_ROOT, 'wwebjs');
const CACHE_DIR = path.join(WWEBJS_DIR, '.wwebjs_cache');
const EXEC_DIR = path.join(USER_ROOT, 'exec');
// Packaged: use Chrome bundled via electron-builder `extraResources`.
// Dev: fall back to userData so `npm start` can self-download on first run.
const PUPPETEER_CACHE_DIR = IS_PACKAGED
	? path.join(process.resourcesPath, 'chrome-cache')
	: path.join(app.getPath('userData'), 'puppeteer-cache');
const UTIL_INFO_PATH = path.join(ASSETS_DIR, 'utilInfo.json');
const EXTERNAL_INFO_PATH = path.join(ASSETS_DIR, 'externalInfo.json');
const LOGS_PATH = path.join(EXEC_DIR, 'logs.txt');
const ENV_PATH = path.join(USER_ROOT, '.env');
const BOT_SCRIPT = path.join(app.getAppPath(), 'wwebjs', 'bot.js');

let mainWindow = null;
let botProcess = null;
let statusInterval = null;
let chromeReady = false;
let ensureChromePromise = null;

function seedUserData() {
	if (!IS_PACKAGED) return;
	fs.mkdirSync(ASSETS_DIR, { recursive: true });
	fs.mkdirSync(WWEBJS_DIR, { recursive: true });
	fs.mkdirSync(EXEC_DIR, { recursive: true });
	for (const name of ['utilInfo.json', 'externalInfo.json']) {
		const dest = path.join(ASSETS_DIR, name);
		const src = path.join(BUNDLED_ASSETS, name);
		if (!fs.existsSync(dest) && fs.existsSync(src)) {
			fs.copyFileSync(src, dest);
		}
	}
}

function loadDotEnv() {
	if (!fs.existsSync(ENV_PATH)) return;
	const content = fs.readFileSync(ENV_PATH, 'utf8');
	for (const rawLine of content.split(/\r?\n/)) {
		const line = rawLine.trim();
		if (!line || line.startsWith('#')) continue;
		const idx = line.indexOf('=');
		if (idx < 0) continue;
		const key = line.slice(0, idx).trim();
		const value = line.slice(idx + 1).trim();
		if (key) process.env[key] = value;
	}
}

function appendLog(line) {
	try {
		fs.mkdirSync(path.dirname(LOGS_PATH), { recursive: true });
		fs.appendFileSync(LOGS_PATH, `${new Date().toISOString()} ${line}\n`);
	} catch {}
}

function sendToRenderer(channel, payload) {
	if (mainWindow && !mainWindow.isDestroyed()) {
		mainWindow.webContents.send(channel, payload);
	}
}

function emitStatus() {
	const running = !!(botProcess && botProcess.exitCode === null);
	sendToRenderer('bot:status', { running });
}

function ensureChromeReady() {
	if (chromeReady) return Promise.resolve({ ok: true });
	if (ensureChromePromise) return ensureChromePromise;
	ensureChromePromise = ensureChrome({
		cacheDir: PUPPETEER_CACHE_DIR,
		onProgress: (p) => sendToRenderer('bot:setupProgress', p),
		onExtracting: () => sendToRenderer('bot:setupExtracting'),
	})
		.then((info) => {
			chromeReady = true;
			appendLog(`[setup] chrome ready at ${info.executablePath} (buildId ${info.buildId})`);
			return { ok: true };
		})
		.catch((err) => {
			appendLog(`[setup] chrome install failed: ${err.message}`);
			return { ok: false, error: err.message };
		})
		.finally(() => {
			ensureChromePromise = null;
		});
	return ensureChromePromise;
}

async function startBot() {
	if (botProcess && botProcess.exitCode === null) {
		return { ok: true, alreadyRunning: true };
	}

	const ready = await ensureChromeReady();
	if (!ready.ok) return ready;

	try {
		botProcess = spawn(process.execPath, [BOT_SCRIPT], {
			cwd: WWEBJS_DIR,
			env: {
				...process.env,
				ELECTRON_RUN_AS_NODE: '1',
				FACOM_ASSETS_DIR: ASSETS_DIR,
				PUPPETEER_CACHE_DIR,
			},
			windowsHide: true,
		});

		botProcess.stdout.on('data', (data) => {
			const text = data.toString();
			appendLog(`[stdout] ${text.trim()}`);
			sendToRenderer('bot:log', { stream: 'stdout', text });
		});
		botProcess.stderr.on('data', (data) => {
			const text = data.toString();
			appendLog(`[stderr] ${text.trim()}`);
			sendToRenderer('bot:log', { stream: 'stderr', text });
		});
		botProcess.on('exit', (code) => {
			appendLog(`bot exited with code ${code}`);
			emitStatus();
		});
		botProcess.on('error', (err) => {
			appendLog(`bot spawn error: ${err.message}`);
		});

		emitStatus();
		return { ok: true };
	} catch (err) {
		appendLog(`startBot error: ${err.message}`);
		return { ok: false, error: err.message };
	}
}

function killProcessTree(pid) {
	return new Promise((resolve) => {
		if (!pid) return resolve();
		if (process.platform === 'win32') {
			exec(`taskkill /pid ${pid} /T /F`, () => resolve());
		} else {
			try { process.kill(pid, 'SIGTERM'); } catch {}
			resolve();
		}
	});
}

async function stopBot() {
	if (!botProcess) return { ok: true };
	const pid = botProcess.pid;
	await killProcessTree(pid);
	botProcess = null;
	emitStatus();
	return { ok: true };
}

async function restartBot() {
	await stopBot();
	await new Promise((r) => setTimeout(r, 3000));
	return startBot();
}

function removeCacheDir() {
	try {
		if (fs.existsSync(CACHE_DIR)) {
			fs.rmSync(CACHE_DIR, { recursive: true, force: true });
		}
	} catch (err) {
		appendLog(`cleanup error: ${err.message}`);
	}
}

function readJson(filePath, fallback) {
	try {
		const raw = fs.readFileSync(filePath, 'utf8');
		return JSON.parse(raw);
	} catch {
		return fallback;
	}
}

function writeJson(filePath, data) {
	fs.mkdirSync(path.dirname(filePath), { recursive: true });
	fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
}

function registerIpc() {
	ipcMain.handle('bot:start', () => startBot());
	ipcMain.handle('bot:stop', () => stopBot());
	ipcMain.handle('bot:restart', () => restartBot());
	ipcMain.handle('bot:getStatus', () => ({
		running: !!(botProcess && botProcess.exitCode === null),
	}));
	ipcMain.handle('bot:ensureBrowser', () => ensureChromeReady());

	ipcMain.handle('config:getUtilInfo', () =>
		readJson(UTIL_INFO_PATH, { phoneNumber: '', greetingText: '' })
	);
	ipcMain.handle('config:saveUtilInfo', (_e, payload) => {
		const phone = String(payload?.phoneNumber ?? '').trim();
		const greeting = String(payload?.greetingText ?? '');
		if (!/^\d{13}$/.test(phone)) {
			return { ok: false, error: 'Número inválido. Use 13 dígitos (Ex: 5571999999999).' };
		}
		writeJson(UTIL_INFO_PATH, { phoneNumber: phone, greetingText: greeting });
		return { ok: true };
	});

	ipcMain.handle('config:getMenuInfo', () => readJson(EXTERNAL_INFO_PATH, []));
	ipcMain.handle('config:saveMenuInfo', (_e, topics) => {
		if (!Array.isArray(topics)) return { ok: false, error: 'Invalid payload' };
		const cleaned = topics
			.map((t) => ({
				topic: String(t?.topic ?? '').trim(),
				subtopics: Array.isArray(t?.subtopics)
					? t.subtopics
						.map((s) => ({
							name: String(s?.name ?? '').trim(),
							description: String(s?.description ?? '').trim(),
						}))
						.filter((s) => s.name && s.description)
					: [],
			}))
			.filter((t) => t.topic);
		writeJson(EXTERNAL_INFO_PATH, cleaned);
		return { ok: true };
	});
}

function createWindow() {
	mainWindow = new BrowserWindow({
		width: 1280,
		height: 900,
		minWidth: 960,
		minHeight: 720,
		backgroundColor: '#f8fafc',
		title: 'FACOM-bot',
		webPreferences: {
			preload: path.join(__dirname, 'preload.js'),
			contextIsolation: true,
			nodeIntegration: false,
			sandbox: false,
		},
	});

	mainWindow.setMenuBarVisibility(false);
	mainWindow.loadFile(path.join(__dirname, 'renderer', 'index.html'));
}

function initAutoUpdater() {
	if (!IS_PACKAGED) return;
	autoUpdater.logger = {
		info: (msg) => appendLog(`[updater] ${msg}`),
		warn: (msg) => appendLog(`[updater][warn] ${msg}`),
		error: (msg) => appendLog(`[updater][error] ${msg}`),
		debug: () => {},
	};
	autoUpdater.autoDownload = true;
	autoUpdater.checkForUpdatesAndNotify().catch((err) => {
		appendLog(`[updater] check failed: ${err.message}`);
	});
}

app.whenReady().then(() => {
	seedUserData();
	loadDotEnv();
	registerIpc();
	createWindow();
	initAutoUpdater();

	statusInterval = setInterval(emitStatus, 5000);

	app.on('activate', () => {
		if (BrowserWindow.getAllWindows().length === 0) createWindow();
	});
});

app.on('before-quit', async (event) => {
	if (statusInterval) { clearInterval(statusInterval); statusInterval = null; }
	if (botProcess && botProcess.exitCode === null) {
		event.preventDefault();
		await stopBot();
		removeCacheDir();
		app.quit();
		return;
	}
	removeCacheDir();
});

app.on('window-all-closed', () => {
	if (process.platform !== 'darwin') app.quit();
});
