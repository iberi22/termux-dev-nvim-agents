# Project Progress Log

Regla: Este archivo debe actualizarse con cada cambio relevante (features, fixes, docs) indicando fecha y resumen.

## 2025-09-25

### Orquestador endurecido y reporting consistente

- `install.sh`: migrado a `set -Eeuo pipefail`, IFS seguro y traps centralizados (`ERR`, `INT`, `EXIT`) con resúmenes finales y códigos de salida preservados; helper genérico `run_with_retry` para `pkg` con reintentos y mensajes estructurados. Los flags `--force`, `--reset-state` y `--clean` ahora generan mensajes de estado homogéneos y la ejecución del `setup` se controla sin `exec` para reportar fallos correctamente.
- `setup.sh`: mismas garantías de strict mode, captura de comandos fallidos y salida con resúmenes en `cleanup`; fallos de módulos actualizan `SCRIPT_EXIT_CODE` aunque la instalación continúe, y la instalación automática registra en `add_summary` el estado escrito en `~/.termux-ai-setup/INSTALL_DONE`.
- Ambos scripts: logging tipo CLI-friendly con `info/warn/error`, instrucciones claras para revisar `setup.log` y sintaxis verificada con `bash -n`.

## 2025-09-24

### Instalador Idempotente y Reanudable

- `setup.sh`: nuevo gestor de estado para módulos (`scripts/module-state.sh`), banderas `--force` y `--reset-state`, y saltos automáticos cuando un módulo ya se completó con la misma versión.
- `install.sh`: reutiliza instalaciones existentes con `git fetch/pull`, añade flags `--force`, `--reset-state` y `--clean`, y propaga las banderas al `setup` sin borrar el repositorio por defecto.
- `modules/00-base-packages.sh`: corrección del color `CYAN`, detección previa de paquetes instalados y bucles idempotentes para esenciales/opcionales.
- `modules/00-system-optimization.sh` y `modules/00-network-fixes.sh`: bloques `.bashrc` y scripts de arranque sólo se añaden una vez; limpieza automática sin duplicados.
- Registro centralizado del estado en `~/.termux-ai-setup/state` para permitir reintentos controlados y evitar instalaciones colgando en pasos ya exitosos.

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

## 2025-01-XX - v2.1 (Instalador Robusto)

### Correcciones Críticas del Instalador

- **modules/03-ai-integration.sh**: Solución completa para errores de node-gyp en Termux:
  - Fix definitivo: `GYP_DEFINES="android_ndk_path=/dev/null"`
  - Variables npm_config completas para compilación nativa
  - Detección inteligente de paquetes ya instalados
  - Verificación robusta con información detallada de PATH
  - Manejo graceful de errores con continuación de instalación

### Modo No Interactivo Completo

- **TERMUX_AI_AUTO=true**: Instalación completamente desatendida implementada en:
  - `modules/00-user-setup.sh`: Configuración automática de usuario y Git
  - `modules/00-base-packages.sh`: Skip de prompts interactivos de Git
  - `modules/03-ai-integration.sh`: Instalación de CLIs sin OAuth automático
  - `modules/05-ssh-setup.sh`: Generación de SSH keys sin prompts
  - `setup.sh`: Deshabilitación de OAuth login automático de Gemini

### Mejoras de Robustez

- **Instalación idempotente**: Detección de componentes ya instalados
- **Verificación mejorada**: Status detallado de CLIs con ubicación de binarios
- **Logs informativos**: Progreso claro y información de debug
- **Manejo de errores**: Continuación graceful ante fallos parciales
- **Configuración por defecto**: Valores sensatos para modo automático

### Status de CLIs de IA

- ✅ **@google/gemini-cli**: Instalación robusta con manejo de errores node-gyp
- ⚠️ **@openai/codex**: Opcional, manejo de fallos graceful
- ⚠️ **@qwen-code/qwen-code**: Opcional, manejo de fallos graceful
- ✅ **Comando `:`**: Wrapper funcional para consultas rápidas a Gemini

### Autenticación Manual Post-Instalación

- OAuth2 automático deshabilitado para evitar prompts interactivos
- Autenticación manual requerida post-instalación:
  - `gemini auth login` para Google Gemini CLI
  - `codex login` para OpenAI Codex (si disponible)
  - `qwen setup` para Qwen Code (si disponible)
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
