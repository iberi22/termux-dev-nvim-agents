# Project Progress Log

Regla: Este archivo debe actualizarse con cada cambio relevante (features, fixes, docs) indicando fecha y resumen.

## 2025-09-23

- v2025-09-22.4: Modo verbose, logs y no interactivo para apt/dpkg.
- Corrección de /tmp→$HOME/.cache establecida previamente; validación con Termux.
- Prompt final: `passwd`, claves SSH y sshd permanente.
- Nuevo `termux-ai-panel` para estado, servicios y utilidades.
- Docs iniciales: SPEC, ROADMAP, TASKS, PROGRESS, AGENTS, GEMINI.

### Mantenimiento y Lint

- QUICK_COMMANDS.md: correcciones de markdownlint (MD005/MD007/MD022/MD031/MD040), enlaces formateados y sección URLs revisada.
- Política OAuth2-only para Gemini reforzada: eliminado `GEMINI_API_KEY` de `config/.ai-env.template` y actualizado enlace a autenticación de Gemini CLI.

### Sistema Post-Instalación Completado

- **setup.sh**: Agregada función `post_installation_setup()` que maneja configuración final:
  - Prompts para establecer contraseña de usuario (`passwd`)
  - Generación y muestra de llaves SSH para GitHub (con instrucciones)
  - Opción para habilitar servidor SSH permanente con `sv-enable sshd`
  - Instalación del comando global `termux-ai-panel`

- **Panel de Control** (`scripts/termux-ai-panel.sh`):
  - Estado del sistema: Node.js, Git, Zsh, Neovim, Gemini CLI, SSH server
  - Uso del disco: tamaños de directorios importantes
  - Proyectos Git: detección automática en `~/src` con estado de cambios
  - Acciones: mostrar llave SSH, habilitar SSH, servidor HTTP en 9999
  - Menú interactivo con opciones 1-9 y 99 para salir

### Interfaz Web Moderna

- **Frontend** (`web-ui/`):
  - Vite + TailwindCSS + WebSockets configurados
  - UI responsive y dark mode por defecto
  - Componentes: sistema health, disk usage, git projects, logs en tiempo real
  - WebSocket client para comunicación bidireccional

- **Backend** (`backend/main.py`):
  - FastAPI + Socket.IO para WebSockets
  - Endpoints REST y eventos WebSocket
  - Monitoreo automático del sistema cada 10 segundos
  - Acciones: mostrar SSH key, habilitar SSH, gestión de proyectos
  - Servir frontend estático desde `/`

- **Launcher** (`start-panel.sh`):
  - Comandos: `install`, `dev`, `build`, `start`, `stop`, `status`
  - Manejo de dependencias Python (venv) y Node.js
  - Servidores de desarrollo en puertos 3000 (frontend) y 8000 (backend)
  - Cleanup automático con Ctrl+C

### Integración en setup.sh

- Nueva opción 12 en menú principal: "🎛️ Panel de Control Post-Instalación"
- Panel accesible desde instalación principal y como comando independiente
- Opción 7 en panel para lanzar interfaz web completa (Vite + FastAPI)

### Documentación

- AGENTS.md creado con detalle de agentes y uso del comando `:`.
- GEMINI.md creado con guía completa de instalación, OAuth2, modelos y headless.
- README actualizado con enlaces a docs y regla de mantener PROGRESS.md.
- ROADMAP actualizado: AGENTS.md y GEMINI.md marcados como completados.
