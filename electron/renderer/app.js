const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

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

async function saveUtilInfo(msgId) {
	const res = await window.facom.saveUtilInfo({
		phoneNumber: $('#celular').value,
		greetingText: $('#saudacao').value,
	});
	if (res.ok) showMessage(msgId, 'Atualizado com sucesso.', true);
	else showMessage(msgId, res.error || 'Erro ao salvar.', false);
}

$('#btn-save-phone').addEventListener('click', () => saveUtilInfo('celular-msg'));
$('#btn-save-greeting').addEventListener('click', () => saveUtilInfo('saudacao-msg'));

// Bot controls
async function withStatus(fn, transientText) {
	$('#status-text').textContent = transientText;
	try { await fn(); } catch (err) { console.error(err); }
}
$('#btn-start').addEventListener('click', () =>
	withStatus(() => window.facom.startBot(), 'Iniciando chatBot...')
);
$('#btn-restart').addEventListener('click', () =>
	withStatus(() => window.facom.restartBot(), 'Reiniciando...')
);
$('#btn-stop').addEventListener('click', () =>
	withStatus(() => window.facom.stopBot(), 'Desativando chatbot, por favor aguarde...')
);

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

$('#btn-save-menu').addEventListener('click', async () => {
	const res = await window.facom.saveMenuInfo(topics);
	if (res.ok) showMessage('menu-msg', 'Menu atualizado com sucesso.', true);
	else showMessage('menu-msg', res.error || 'Erro ao salvar.', false);
});

// Initial load
loadUtilInfo();
