const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('facom', {
	startBot: () => ipcRenderer.invoke('bot:start'),
	stopBot: () => ipcRenderer.invoke('bot:stop'),
	restartBot: () => ipcRenderer.invoke('bot:restart'),
	getStatus: () => ipcRenderer.invoke('bot:getStatus'),
	ensureBrowser: () => ipcRenderer.invoke('bot:ensureBrowser'),
	onSetupProgress: (cb) => {
		const listener = (_e, payload) => cb(payload);
		ipcRenderer.on('bot:setupProgress', listener);
		return () => ipcRenderer.removeListener('bot:setupProgress', listener);
	},
	onSetupExtracting: (cb) => {
		const listener = () => cb();
		ipcRenderer.on('bot:setupExtracting', listener);
		return () => ipcRenderer.removeListener('bot:setupExtracting', listener);
	},
	onStatus: (cb) => {
		const listener = (_e, payload) => cb(payload);
		ipcRenderer.on('bot:status', listener);
		return () => ipcRenderer.removeListener('bot:status', listener);
	},
	onLog: (cb) => {
		const listener = (_e, payload) => cb(payload);
		ipcRenderer.on('bot:log', listener);
		return () => ipcRenderer.removeListener('bot:log', listener);
	},

	getUtilInfo: () => ipcRenderer.invoke('config:getUtilInfo'),
	saveUtilInfo: (payload) => ipcRenderer.invoke('config:saveUtilInfo', payload),
	getMenuInfo: () => ipcRenderer.invoke('config:getMenuInfo'),
	saveMenuInfo: (topics) => ipcRenderer.invoke('config:saveMenuInfo', topics),
});
