import './style.css';
import { io } from 'socket.io-client';

// WebSocket connection (will connect to FastAPI backend)
const socket = io('http://localhost:8000');

// DOM elements
const app = document.getElementById('app');

// Application state
let systemStatus = {
  node: false,
  git: false,
  zsh: false,
  neovim: false,
  gemini: false,
  ssh: false
};

let diskUsage = {};
let gitProjects = [];

// Initialize the application
function init() {
  renderApp();
  setupEventListeners();
  connectWebSocket();
}

// Render the main application
function renderApp() {
  app.innerHTML = `
    <div class="container mx-auto px-4 py-8 max-w-6xl">
      <!-- Header -->
      <header class="mb-8">
        <h1 class="text-4xl font-bold text-center mb-2">
          🤖 Termux AI Control Panel
        </h1>
        <p class="text-gray-400 text-center">
          Sistema de gestión post-instalación para entorno de desarrollo con IA
        </p>
      </header>

      <!-- Status Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
        <!-- System Health Card -->
        <div class="card">
          <h2 class="text-xl font-semibold mb-4 flex items-center">
            🏥 Estado del Sistema
          </h2>
          <div id="system-status">
            ${renderSystemStatus()}
          </div>
        </div>

        <!-- Disk Usage Card -->
        <div class="card">
          <h2 class="text-xl font-semibold mb-4 flex items-center">
            💾 Uso del Disco
          </h2>
          <div id="disk-usage">
            ${renderDiskUsage()}
          </div>
        </div>

        <!-- Git Projects Card -->
        <div class="card md:col-span-2 lg:col-span-1">
          <h2 class="text-xl font-semibold mb-4 flex items-center">
            📂 Proyectos Git
          </h2>
          <div id="git-projects">
            ${renderGitProjects()}
          </div>
        </div>
      </div>

      <!-- Actions Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <!-- Quick Actions Card -->
        <div class="card">
          <h2 class="text-xl font-semibold mb-4 flex items-center">
            ⚡ Acciones Rápidas
          </h2>
          <div class="space-y-3">
            <button id="ssh-key-btn" class="btn btn-primary w-full">
              🔑 Mostrar Llave SSH
            </button>
            <button id="enable-ssh-btn" class="btn btn-secondary w-full">
              🌐 Habilitar SSH Server
            </button>
            <button id="http-server-btn" class="btn btn-success w-full">
              🖥️ Iniciar HTTP Server (9999)
            </button>
            <div class="grid grid-cols-2 gap-3">
              <button id="gemini-auth-status-btn" class="btn w-full">🤖 Estado Auth Gemini</button>
              <button id="gemini-login-btn" class="btn w-full">🔐 Login Gemini</button>
            </div>
            <div class="grid grid-cols-2 gap-3">
              <button id="ssh-test-btn" class="btn w-full">🔍 Probar SSH GitHub</button>
              <button id="copy-ssh-key-btn" class="btn w-full">📋 Copiar Llave SSH</button>
            </div>
          </div>
        </div>

        <!-- Connection Status Card -->
        <div class="card">
          <h2 class="text-xl font-semibold mb-4 flex items-center">
            🔗 Estado de Conexión
          </h2>
          <div id="connection-status">
            <div class="flex items-center space-x-2">
              <span id="ws-status" class="status-offline">
                WebSocket: Desconectado
              </span>
            </div>
            <div class="mt-2 text-sm text-gray-400">
              <p>Backend: <span id="backend-status">Verificando...</span></p>
              <p>HTTP Server: <span id="http-status">Inactivo</span></p>
            </div>
          </div>
        </div>
      </div>

      <!-- Logs Card -->
      <div class="card">
        <h2 class="text-xl font-semibold mb-4 flex items-center">
          📝 Logs del Sistema
        </h2>
        <div id="system-logs" class="bg-gray-900 rounded p-4 font-mono text-sm max-h-64 overflow-y-auto">
          <div class="text-green-400">[INFO] Panel de control iniciado</div>
          <div class="text-blue-400">[INFO] Esperando conexión WebSocket...</div>
        </div>
      </div>
    </div>
  `;
}

// Render system status
function renderSystemStatus() {
  const services = [
    { name: 'Node.js', key: 'node' },
    { name: 'Git', key: 'git' },
    { name: 'Zsh', key: 'zsh' },
    { name: 'Neovim', key: 'neovim' },
    { name: 'Gemini CLI', key: 'gemini' },
    { name: 'SSH Server', key: 'ssh' }
  ];

  return services.map(service => {
    const status = systemStatus[service.key];
    const statusClass = status ? 'status-online' : 'status-offline';
    const statusText = status ? 'Online' : 'Offline';

    return `
      <div class="flex justify-between items-center py-2">
        <span>${service.name}</span>
        <span class="${statusClass}">${statusText}</span>
      </div>
    `;
  }).join('');
}

// Render disk usage
function renderDiskUsage() {
  if (Object.keys(diskUsage).length === 0) {
    return '<p class="text-gray-400">Cargando información del disco...</p>';
  }

  return Object.entries(diskUsage).map(([path, size]) => `
    <div class="flex justify-between items-center py-2">
      <span class="text-sm">${path}</span>
      <span class="text-blue-400 font-mono">${size}</span>
    </div>
  `).join('');
}

// Render git projects
function renderGitProjects() {
  if (gitProjects.length === 0) {
    return '<p class="text-gray-400">No hay proyectos Git detectados</p>';
  }

  return gitProjects.map(project => `
    <div class="border-b border-gray-700 pb-2 mb-2 last:border-b-0">
      <div class="flex justify-between items-center">
        <span class="font-medium">${project.name}</span>
        <span class="text-sm text-blue-400">${project.branch}</span>
      </div>
      <div class="text-sm ${project.hasChanges ? 'text-red-400' : 'text-green-400'}">
        ${project.hasChanges ? '🔴 Cambios pendientes' : '✅ Sin cambios'}
      </div>
    </div>
  `).join('');
}

// Setup event listeners
function setupEventListeners() {
  // SSH Key button
  document.getElementById('ssh-key-btn').addEventListener('click', () => {
    socket.emit('action', { type: 'show_ssh_key' });
    addLog('[ACTION] Solicitando llave SSH...', 'info');
  });

  // Enable SSH button
  document.getElementById('enable-ssh-btn').addEventListener('click', () => {
    socket.emit('action', { type: 'enable_ssh' });
    addLog('[ACTION] Habilitando servidor SSH...', 'info');
  });

  // HTTP Server button
  document.getElementById('http-server-btn').addEventListener('click', () => {
    socket.emit('action', { type: 'start_http_server' });
    addLog('[ACTION] Iniciando servidor HTTP en puerto 9999...', 'info');
  });

  // Gemini auth status
  document.getElementById('gemini-auth-status-btn').addEventListener('click', () => {
    socket.emit('action', { type: 'gemini_auth_status' });
    addLog('[ACTION] Verificando estado de autenticación de Gemini...', 'info');
  });

  // Gemini login
  document.getElementById('gemini-login-btn').addEventListener('click', () => {
    socket.emit('action', { type: 'gemini_login' });
    addLog('[ACTION] Iniciando login de Gemini...', 'info');
  });

  // Test SSH GitHub
  document.getElementById('ssh-test-btn').addEventListener('click', () => {
    socket.emit('action', { type: 'test_github_ssh' });
    addLog('[ACTION] Probando conexión SSH con GitHub...', 'info');
  });

  // Copy SSH key
  document.getElementById('copy-ssh-key-btn').addEventListener('click', async () => {
    socket.emit('action', { type: 'show_ssh_key' });
    addLog('[ACTION] Solicitando llave SSH para copiar...', 'info');
  });
}

// WebSocket connection
function connectWebSocket() {
  socket.on('connect', () => {
    const wsStatus = document.getElementById('ws-status');
    wsStatus.className = 'status-online';
    wsStatus.textContent = 'WebSocket: Conectado';
    addLog('[WS] Conectado al servidor', 'success');
  });

  socket.on('disconnect', () => {
    const wsStatus = document.getElementById('ws-status');
    wsStatus.className = 'status-offline';
    wsStatus.textContent = 'WebSocket: Desconectado';
    addLog('[WS] Desconectado del servidor', 'error');
  });

  socket.on('system_status', (data) => {
    systemStatus = data;
    document.getElementById('system-status').innerHTML = renderSystemStatus();
    addLog('[UPDATE] Estado del sistema actualizado', 'info');
  });

  socket.on('disk_usage', (data) => {
    diskUsage = data;
    document.getElementById('disk-usage').innerHTML = renderDiskUsage();
    addLog('[UPDATE] Uso del disco actualizado', 'info');
  });

  socket.on('git_projects', (data) => {
    gitProjects = data;
    document.getElementById('git-projects').innerHTML = renderGitProjects();
    addLog('[UPDATE] Proyectos Git actualizados', 'info');
  });

  socket.on('ssh_key', (data) => {
    showModal('SSH Public Key', `<pre class="bg-gray-900 p-4 rounded text-sm overflow-x-auto">${data.key}</pre>`);
    addLog('[SSH] Llave pública mostrada', 'success');
  });

  socket.on('log', (data) => {
    addLog(data.message, data.level);
  });

  socket.on('gemini_auth', (data) => {
    const text = data.authenticated ? 'Gemini autenticado' : 'Gemini no autenticado';
    addLog(`[GEMINI] ${text}`, data.authenticated ? 'success' : 'warning');
  });

  socket.on('gemini_auth_flow', (data) => {
    const url = data.url;
    showModal('Completar Login de Gemini', `
      <p class="mb-2">Abre la siguiente URL para completar el login:</p>
      <p><a href="${url}" target="_blank" class="text-blue-400 underline">${url}</a></p>
    `);
    addLog('[GEMINI] URL de autenticación mostrada', 'info');
  });

  socket.on('task_start', (data) => {
    addLog(`[TASK] Iniciando ${data.task}`, 'info');
  });
  socket.on('task_log', (data) => {
    addLog(data.message, data.level);
  });
  socket.on('task_complete', (data) => {
    const level = data.exitCode === 0 ? 'success' : 'error';
    addLog(`[TASK] Finalizó ${data.task} (exit ${data.exitCode})`, level);
  });
}

// Add log entry
function addLog(message, level = 'info') {
  const logsContainer = document.getElementById('system-logs');
  const timestamp = new Date().toLocaleTimeString();
  const levelColors = {
    info: 'text-blue-400',
    success: 'text-green-400',
    warning: 'text-yellow-400',
    error: 'text-red-400'
  };

  const logEntry = document.createElement('div');
  logEntry.className = levelColors[level] || 'text-gray-400';
  logEntry.textContent = `[${timestamp}] ${message}`;

  logsContainer.appendChild(logEntry);
  logsContainer.scrollTop = logsContainer.scrollHeight;
}

// Show modal (simple implementation)
function showModal(title, content) {
  const modal = document.createElement('div');
  modal.className = 'fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50';
  modal.innerHTML = `
    <div class="bg-gray-800 rounded-lg p-6 max-w-2xl w-full mx-4 max-h-96 overflow-y-auto">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-xl font-semibold">${title}</h3>
        <button class="text-gray-400 hover:text-white text-2xl" onclick="this.closest('.fixed').remove()">
          ×
        </button>
      </div>
      <div>${content}</div>
    </div>
  `;

  document.body.appendChild(modal);
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', init);