const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

// Toast + busy-state helpers
const TOAST_STYLES = {
	success: 'bg-emerald-600 text-white',
	error: 'bg-rose-600 text-white',
	info: 'bg-slate-800 text-white',
};
function showToast(message, type = 'info') {
	const container = $('#toast-container');
	if (!container) return;
	const toast = document.createElement('div');
	toast.className = `pointer-events-auto px-4 py-3 rounded-lg shadow-lg text-sm font-medium transition-opacity duration-300 ${TOAST_STYLES[type] || TOAST_STYLES.info}`;
	toast.textContent = message;
	container.appendChild(toast);
	setTimeout(() => { toast.style.opacity = '0'; }, 2700);
	setTimeout(() => { toast.remove(); }, 3100);
}

const SPINNER_SVG = '<svg class="animate-spin h-5 w-5 inline-block -mt-0.5 mr-2" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path></svg>';

function setButtonBusy(button, busyText) {
	const label = button.querySelector('.btn-label');
	if (label && button.dataset._origLabel == null) {
		button.dataset._origLabel = label.innerHTML;
		label.innerHTML = `${SPINNER_SVG}${busyText}`;
	}
	button.disabled = true;
}
function clearButtonBusy(button) {
	const label = button.querySelector('.btn-label');
	if (label && button.dataset._origLabel != null) {
		label.innerHTML = button.dataset._origLabel;
		delete button.dataset._origLabel;
	}
	button.disabled = false;
}

let actionBusy = false;
async function withAction(clickedBtn, busyText, fn, messages = {}) {
	if (actionBusy) return;
	actionBusy = true;
	const actionButtons = $$('.action-btn');
	actionButtons.forEach((b) => { b.disabled = true; });
	setButtonBusy(clickedBtn, busyText);
	try {
		const res = await fn();
		if (res && res.ok === false) {
			showToast(messages.error || res.error || 'Falha na operação.', 'error');
		} else {
			showToast(messages.success || 'Operação concluída.', 'success');
		}
	} catch (err) {
		console.error(err);
		showToast(messages.error || `Erro: ${err.message || err}`, 'error');
	} finally {
		clearButtonBusy(clickedBtn);
		actionButtons.forEach((b) => { b.disabled = false; });
		actionBusy = false;
	}
}

async function withSaveBusy(clickedBtn, fn, messages = {}) {
	setButtonBusy(clickedBtn, 'Salvando…');
	try {
		const res = await fn();
		if (res && res.ok === false) {
			showToast(messages.error || res.error || 'Falha ao salvar.', 'error');
			return res;
		}
		showToast(messages.success || 'Salvo com sucesso.', 'success');
		return res;
	} catch (err) {
		console.error(err);
		showToast(`Erro: ${err.message || err}`, 'error');
	} finally {
		clearButtonBusy(clickedBtn);
	}
}

// Navigation
function showPage(name) {
	$$('.page').forEach((p) => p.classList.add('hidden-page'));
	$(`#page-${name}`).classList.remove('hidden-page');
	$$('.nav-btn').forEach((btn) => {
		if (btn.dataset.nav === name) {
			btn.classList.add('bg-emerald-50', 'text-emerald-700', 'font-semibold');
			btn.classList.remove('text-slate-500', 'font-medium');
		} else {
			btn.classList.remove('bg-emerald-50', 'text-emerald-700', 'font-semibold');
			btn.classList.add('text-slate-500', 'font-medium');
		}
	});
	if (name === 'menu') loadMenu();
}
$$('.nav-btn').forEach((btn) => btn.addEventListener('click', () => showPage(btn.dataset.nav)));

// Status indicator
function updateStatusUI(running) {
	const dot = $('#status-dot');
	const text = $('#status-text');
	if (running) {
		dot.classList.remove('bg-amber-500');
		dot.classList.add('bg-emerald-500');
		text.textContent = 'Chatbot ativo.';
	} else {
		dot.classList.remove('bg-emerald-500');
		dot.classList.add('bg-amber-500');
		text.textContent = 'Por favor, inicie o sistema.';
	}
}
window.facom.onStatus(({ running }) => updateStatusUI(running));
window.facom.getStatus().then(({ running }) => updateStatusUI(running));

// Logs
const logArea = $('#log-area');
window.facom.onLog(({ stream, text }) => {
	const prefix = stream === 'stderr' ? '[err] ' : '';
	logArea.textContent += prefix + text;
	logArea.scrollTop = logArea.scrollHeight;
});
$('#btn-clear-logs').addEventListener('click', () => { logArea.textContent = ''; });

// Util info (phone + greeting)
function showMessage(id, message, ok) {
	const el = $(`#${id}`);
	el.textContent = message;
	el.classList.remove('hidden', 'text-red-500', 'text-emerald-600');
	el.classList.add(ok ? 'text-emerald-600' : 'text-red-500');
	setTimeout(() => el.classList.add('hidden'), 4000);
}

async function loadUtilInfo() {
	const info = await window.facom.getUtilInfo();
	$('#celular').value = info.phoneNumber || '';
	$('#saudacao').value = info.greetingText || '';
}

async function saveUtilInfo(btn, msgId) {
	const res = await withSaveBusy(
		btn,
		() => window.facom.saveUtilInfo({
			phoneNumber: $('#celular').value,
			greetingText: $('#saudacao').value,
		}),
		{ success: 'Configuração atualizada.', error: 'Não foi possível salvar.' }
	);
	if (!res) return;
	if (res.ok) showMessage(msgId, 'Atualizado com sucesso.', true);
	else showMessage(msgId, res.error || 'Erro ao salvar.', false);
}

$('#btn-save-phone').addEventListener('click', (e) => saveUtilInfo(e.currentTarget, 'celular-msg'));
$('#btn-save-greeting').addEventListener('click', (e) => saveUtilInfo(e.currentTarget, 'saudacao-msg'));

// Bot controls
$('#btn-start').addEventListener('click', (e) => {
	$('#status-text').textContent = 'Iniciando chatBot...';
	return withAction(e.currentTarget, 'Iniciando…', () => window.facom.startBot(), {
		success: 'Bot iniciado.',
		error: 'Falha ao iniciar o bot.',
	});
});
$('#btn-restart').addEventListener('click', (e) => {
	$('#status-text').textContent = 'Reiniciando...';
	return withAction(e.currentTarget, 'Reiniciando…', () => window.facom.restartBot(), {
		success: 'Bot reiniciado.',
		error: 'Falha ao reiniciar o bot.',
	});
});
$('#btn-stop').addEventListener('click', (e) => {
	$('#status-text').textContent = 'Desativando chatbot, por favor aguarde...';
	return withAction(e.currentTarget, 'Desligando…', () => window.facom.stopBot(), {
		success: 'Bot desligado.',
		error: 'Falha ao desligar o bot.',
	});
});

// Menu Info editor
let topics = [];

function renderTopics() {
	const container = $('#topics-container');
	container.innerHTML = '';
	topics.forEach((t, ti) => {
		const card = document.createElement('div');
		card.className = 'bg-white rounded-xl border border-slate-200 shadow-sm p-6 space-y-4';
		card.innerHTML = `
			<div class="flex items-center gap-3">
				<span class="text-xs font-bold text-slate-400 uppercase w-8">#${ti + 1}</span>
				<input class="topic-name flex-1 rounded-lg border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 text-sm p-2 bg-slate-50" value="" placeholder="Nome do tópico" />
				<button class="btn-add-sub text-xs font-semibold text-emerald-700 hover:text-emerald-800">+ Subtópico</button>
				<button class="btn-remove-topic text-xs font-semibold text-rose-600 hover:text-rose-700">Remover</button>
			</div>
			<div class="subs space-y-3 pl-10"></div>
		`;
		card.querySelector('.topic-name').value = t.topic || '';
		card.querySelector('.topic-name').addEventListener('input', (e) => { t.topic = e.target.value; });
		card.querySelector('.btn-remove-topic').addEventListener('click', () => {
			topics.splice(ti, 1); renderTopics();
		});
		card.querySelector('.btn-add-sub').addEventListener('click', () => {
			t.subtopics = t.subtopics || [];
			t.subtopics.push({ name: '', description: '' });
			renderTopics();
		});
		const subs = card.querySelector('.subs');
		(t.subtopics || []).forEach((s, si) => {
			const row = document.createElement('div');
			row.className = 'grid grid-cols-12 gap-3 items-start';
			row.innerHTML = `
				<input class="sub-name col-span-4 rounded-lg border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 text-sm p-2 bg-slate-50" placeholder="Nome do subtópico" />
				<textarea class="sub-desc col-span-7 rounded-lg border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 text-sm p-2 bg-slate-50 resize-none" rows="2" placeholder="Descrição"></textarea>
				<button class="btn-remove-sub col-span-1 text-xs text-rose-600 hover:text-rose-700 self-center">Remover</button>
			`;
			row.querySelector('.sub-name').value = s.name || '';
			row.querySelector('.sub-desc').value = s.description || '';
			row.querySelector('.sub-name').addEventListener('input', (e) => { s.name = e.target.value; });
			row.querySelector('.sub-desc').addEventListener('input', (e) => { s.description = e.target.value; });
			row.querySelector('.btn-remove-sub').addEventListener('click', () => {
				t.subtopics.splice(si, 1); renderTopics();
			});
			subs.appendChild(row);
		});
		container.appendChild(card);
	});
}

async function loadMenu() {
	topics = await window.facom.getMenuInfo();
	if (!Array.isArray(topics)) topics = [];
	renderTopics();
}

$('#btn-add-topic').addEventListener('click', () => {
	topics.push({ topic: '', subtopics: [] });
	renderTopics();
});

$('#btn-save-menu').addEventListener('click', async (e) => {
	const res = await withSaveBusy(
		e.currentTarget,
		() => window.facom.saveMenuInfo(topics),
		{ success: 'Menu atualizado.', error: 'Falha ao atualizar o menu.' }
	);
	if (!res) return;
	if (res.ok) showMessage('menu-msg', 'Menu atualizado com sucesso.', true);
	else showMessage('menu-msg', res.error || 'Erro ao salvar.', false);
});

// Browser setup (first-run Chrome download)
const setupOverlay = $('#setup-overlay');
const setupBar = $('#setup-bar');
const setupPercent = $('#setup-percent');
const setupTitle = $('#setup-title');
const setupMessage = $('#setup-message');
const setupIcon = $('#setup-icon');
const setupRetry = $('#setup-retry');
const setupProgressBlock = $('#setup-progress-block');
const setupExtracting = $('#setup-extracting');

function showSetupOverlay() {
	setupOverlay.classList.remove('hidden');
}
function hideSetupOverlay() {
	setupOverlay.classList.add('hidden');
}
function setSetupProgress(downloaded, total) {
	if (!total) {
		setupPercent.textContent = `${(downloaded / 1024 / 1024).toFixed(1)} MB`;
		return;
	}
	const pct = Math.min(100, Math.round((downloaded / total) * 100));
	setupBar.style.width = `${pct}%`;
	setupPercent.textContent = `${pct}% · ${(downloaded / 1024 / 1024).toFixed(1)} / ${(total / 1024 / 1024).toFixed(1)} MB`;
}
function showExtractingState() {
	setupTitle.textContent = 'Instalando navegador…';
	setupMessage.textContent = 'Download concluído. Agora estamos extraindo os arquivos do navegador.';
	setupIcon.textContent = 'hourglass_top';
	setupProgressBlock.classList.add('hidden');
	setupExtracting.classList.remove('hidden');
}
function setSetupError(errorMessage) {
	setupTitle.textContent = 'Falha ao preparar navegador';
	setupMessage.textContent = errorMessage || 'Ocorreu um erro inesperado.';
	setupIcon.textContent = 'error';
	setupIcon.classList.remove('text-emerald-600');
	setupIcon.classList.add('text-rose-600');
	setupBar.classList.remove('bg-emerald-500');
	setupBar.classList.add('bg-rose-500');
	setupProgressBlock.classList.remove('hidden');
	setupExtracting.classList.add('hidden');
	setupRetry.classList.remove('hidden');
}
function resetSetupUI() {
	setupTitle.textContent = 'Preparando navegador…';
	setupMessage.textContent = 'Baixando o navegador necessário para o bot. Isso acontece apenas na primeira execução.';
	setupIcon.textContent = 'download';
	setupIcon.classList.add('text-emerald-600');
	setupIcon.classList.remove('text-rose-600');
	setupBar.classList.add('bg-emerald-500');
	setupBar.classList.remove('bg-rose-500');
	setupBar.style.width = '0%';
	setupPercent.textContent = '0%';
	setupProgressBlock.classList.remove('hidden');
	setupExtracting.classList.add('hidden');
	setupRetry.classList.add('hidden');
}

window.facom.onSetupProgress(({ downloaded, total }) => setSetupProgress(downloaded, total));
window.facom.onSetupExtracting(() => showExtractingState());

async function runSetup() {
	resetSetupUI();
	$('#btn-start').disabled = true;
	$('#btn-restart').disabled = true;
	// Only show the overlay if ensureBrowser takes longer than ~300ms — when
	// Chrome is bundled with the installer, it returns instantly and an
	// overlay flash is noise.
	const showTimer = setTimeout(() => showSetupOverlay(), 300);
	const res = await window.facom.ensureBrowser();
	clearTimeout(showTimer);
	if (res && res.ok) {
		hideSetupOverlay();
		$('#btn-start').disabled = false;
		$('#btn-restart').disabled = false;
	} else {
		showSetupOverlay();
		setSetupError(res && res.error);
	}
}

setupRetry.addEventListener('click', () => runSetup());

runSetup();

// Initial load
loadUtilInfo();
