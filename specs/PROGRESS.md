# Project Progress Log

Regla: Este archivo debe actualizarse con cada cambio relevante (features, fixes, docs) indicando fecha y resumen.

## 2026-11-03 (v0.2.0)

### Instalador interactivo, cinco CLIs de IA y README en inglés

- **Instalador interactivo**: `setup.sh` añade una fase de selección de componentes por grupos
  (Base system, Shell + editor, AI CLIs, SSH) con submenú por CLI. Comandos: `1-4` alternar,
  `a` todo, `n` nada, `d` instalar, `q` salir. El grupo base queda siempre activo.
- **Sin menú cuando no hay TTY**: `curl ... | bash` sigue instalando todo, y se añaden
  `--components=claude,opencode,codex` y `--no-menu` para automatización.
- **Se retira el CLI de IA de Google**: ya no existe; se elimina del instalador, del panel, del
  backend, del web UI, de la configuración de Neovim y de la documentación (guía del CLI borrada).
- **Cinco CLIs**: `claude` (`@anthropic-ai/claude-code`), `opencode` (`opencode-ai`),
  `codex` (`@openai/codex`), `wrangler` (`wrangler`) y `agy` (Google Antigravity, manual desde
  https://antigravity.google).
- `modules/03-ai-integration.sh` reescrito como framework per-CLI idempotente con tabla resumen
  (componente / estado / versión). `agy` nunca hace fallar el módulo.
- `scripts/validate-agents.sh` valida los cinco CLIs y trata la ausencia de `agy` como warning.
  Corregido el uso de `local` fuera de función que rompía la validación.
- `backend/main.py` y `web-ui/src/main.js` listan y detectan los cinco CLIs (`shutil.which`).
- `package.json` sube a `0.2.0`; se añade este `CHANGELOG.md`.
- **README reescrito en inglés**: requisitos, uno-liner, menú interactivo, tabla de lo instalado,
  uso, troubleshooting y desinstalación.

## 2025-09-25 (v3)

### Licencia, Versionado y Despliegue Final

- **Licencia añadida**: MIT License with Non-Commercial Restriction (libre uso/modificación, sin venta comercial)
- **Sistema de versionado mejorado**: Versión actualizada a v2025-09-25.1b42aca en install.sh y README.md
- **Script de versionado manual**: `scripts/update-version-manual.sh` para futuras actualizaciones fáciles
- **Lints verificados**: Código 100% limpio (ShellCheck sin errores)
- **Despliegue exitoso**: Push a main completado, specs documentation restaurada
- **GitHub CI**: Pipeline ejecutándose, vulnerabilidades dependabot detectadas para revisión

## 2025-09-25 (v2)

### Refactoring Completo - Implementación Spec-Kit Minimalista

- **Eliminación de código legacy**: Funciones rastafari obsoletas en `01-zsh-setup.sh`, archivo duplicado `03-ai-integration-updated.sh`
- **Consolidación de scripts**: Eliminados scripts CI/CD no esenciales (`ci-local.sh`, `update-version.sh`, `colon-command.sh`), mantenidos solo los core
- **Estructura spec-kit implementada**: Documentación consolidada en README.md + AGENTS.md + carpeta specs/
- **Limpieza documentación**: Eliminados 10+ archivos .md obsoletos, información consolidada en README con sección Windows
- **Referencias specs restauradas**: Enlaces a SPEC.md, ROADMAP.md, TASKS.md, PROGRESS.md en README.md
- **Package.json actualizado**: Scripts simplificados, referencias a archivos eliminados removidas

## 2025-01-09

### Sistema de Versionado Automático Implementado

- `scripts/update-version.sh`: Script nuevo para actualizar automáticamente la versión en install.sh usando fecha y hash del commit
  - Formato de versión: YYYY-MM-DD.commit-hash (ej: 2025-09-25.7a37c76)
  - Actualiza SCRIPT_VERSION y SCRIPT_COMMIT automáticamente
  - Verificación integrada para asegurar que los cambios se aplicaron correctamente
- `scripts/pre-commit.sh`: Modificado para ejecutar actualización de versión automáticamente antes de cada commit
  - Actualiza versión y hace stage automático de install.sh si fue modificado
  - Mantiene compatibilidad con validaciones de linting existentes
- `.github/workflows/ci.yml`: Actualizado para incluir paso de actualización de versión en CI
  - Se ejecuta antes de las validaciones de sintaxis
  - Asegura versionado consistente en builds automatizados
- `install.sh`: Actualizado para usar versionado dinámico
  - SCRIPT_VERSION ahora usa formato fecha.commit-hash
  - SCRIPT_COMMIT contiene el hash corto del commit actual
  - Sistema probado y funcionando correctamente

## 2025-09-25

### Refactorización Completa del Módulo Zsh con Selección de Tema

- `modules/01-zsh-setup.sh`: refactorización completa con sistema de selección de tema interactivo
  - Tema Rastafari: colores rojo/amarillo/verde con bloques visuales completos
  - Tema Minimalista: solo nombre de directorio, ícono de git y uso de RAM (colores azul/verde/cyan)
  - Función `select_zsh_theme()` para elección interactiva con validación
  - Funciones separadas `configure_rastafari_theme()` y `configure_minimal_theme()` para configuración específica
  - Creación de `create_minimal_p10k_config()` y `create_minimal_zshrc()` para tema minimalista
  - Eliminación de tips extensivos y limpieza completa del código
  - Corrección de errores de sintaxis en heredocs y estructura del código
  - Mantenimiento de fuente FiraCode Mono para ambos temas
- Validación con lints: código verificado sin errores de sintaxis
- Despliegue: cambios commited y pushed a rama main exitosamente

### Instalacion base saneada y CLI de IA resiliente

- `modules/00-base-packages.sh`: elimina pkg de la lista esencial, reemplaza exa por eza en los opcionales y ajusta aliases para usar eza como reemplazo transparente.
- `setup.sh`: agrega helpers de entorno npm e instalacion con reintentos, asegura Node/npm antes de instalar y aplica reintentos con registro en el log.
- Resultado: la corrida base deja de fallar por paquetes inexistentes y la instalacion del CLI de IA es ahora tolerante a errores transitorios.

### Termux UX y resiliencia del setup automático

- `config/configure-zsh-final.sh`: habilita `terminal-onclick-url-open` y `clipboard-autocopy` para que los enlaces sean tocables y las selecciones se copien al portapapeles por defecto.
- `modules/02-neovim-setup.sh`: separa la instalación de TypeScript/TSLS y Biome, usa `@biomejs/biome@latest` según la guía oficial y advierte con enlaces de fallback si npm falla.
- `modules/05-ssh-setup.sh`: corrige bloques heredados que introducían un `fi` huérfano, restaurando el flujo de configuración de Git en modo no automático.
- `setup.sh`: trata los fallos de `sv-enable`/`sv up` como advertencias tanto en modo automático como interactivo, evitando abortos del setup cuando termux-services no está disponible o el servicio ya estaba gestionado.
- `setup.sh`: agrega utilidades `ensure_termux_user_entry`/`set_termux_user_password` para registrar el usuario `termux`, establecer contraseña `termux` cuando hay permisos y omitir la configuración automática de Git (se delega al módulo 05).
- `install.sh` y `modules/07-local-ssh-server.sh`: sincronizan el password por defecto (`termux`) para las credenciales SSH documentadas.
- Resultado: la experiencia en Termux vuelve a permitir abrir URLs con un tap, la instalación automática ya no se interrumpe por dependencias opcionales y deja listo el usuario `termux`/`termux` con llaves SSH sin tocar la configuración de Git (delegada).

## 2025-09-24

### Orquestador endurecido y reporting consistente

- `install.sh`: migrado a `set -Eeuo pipefail`, IFS seguro y traps centralizados (`ERR`, `INT`, `EXIT`) con resúmenes finales y códigos de salida preservados; helper genérico `run_with_retry` para `pkg` con reintentos y mensajes estructurados. Los flags `--force`, `--reset-state` y `--clean` ahora generan mensajes de estado homogéneos y la ejecución del `setup` se controla sin `exec` para reportar fallos correctamente.
- `setup.sh`: mismas garantías de strict mode, captura de comandos fallidos y salida con resúmenes en `cleanup`; fallos de módulos actualizan `SCRIPT_EXIT_CODE` aunque la instalación continúe, y la instalación automática registra en `add_summary` el estado escrito en `~/.termux-ai-setup/INSTALL_DONE`.
- Ambos scripts: logging tipo CLI-friendly con `info/warn/error`, instrucciones claras para revisar `setup.log` y sintaxis verificada con `bash -n`.
- `scripts/validate-agents.sh`: nuevo orquestador de validaciones (core checks: git, node, npm, zsh, curl, wget) con salida estructurada para facilitar la detección del componente fallido.

## 2025-09-22

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
- Docs iniciales: SPEC, ROADMAP, TASKS, PROGRESS y AGENTS.

### Mantenimiento y Lint

- QUICK_COMMANDS.md: correcciones de markdownlint (MD005/MD007/MD022/MD031/MD040), enlaces formateados y sección URLs revisada.
- Política OAuth2-only reforzada: eliminada la API key del CLI de IA en `config/.ai-env.template`.

### Sistema Post-Instalación Completado

- **setup.sh**: Agregada función `post_installation_setup()` que maneja configuración final:
  - Prompts para establecer contraseña de usuario (`passwd`)
  - Generación y muestra de llaves SSH para GitHub (con instrucciones)
  - Opción para habilitar servidor SSH permanente con `sv-enable sshd`
  - Instalación del comando global `termux-ai-panel`

- **Panel de Control** (`scripts/termux-ai-panel.sh`):
  - Estado del sistema: Node.js, Git, Zsh, Neovim, CLIs de IA, SSH server
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
  - `setup.sh`: Deshabilitado el login OAuth automático del CLI de IA durante la instalación

### Mejoras de Robustez

- **Instalación idempotente**: Detección de componentes ya instalados
- **Verificación mejorada**: Status detallado de CLIs con ubicación de binarios
- **Logs informativos**: Progreso claro y información de debug
- **Manejo de errores**: Continuación graceful ante fallos parciales
- **Configuración por defecto**: Valores sensatos para modo automático

### Status de CLIs de IA

- ✅ **CLI de IA principal (npm)**: Instalación robusta con manejo de errores node-gyp
- ⚠️ **@openai/codex**: Opcional, manejo de fallos graceful
- ⚠️ **@qwen-code/qwen-code**: Opcional, manejo de fallos graceful
- ✅ **Comando `g`**: Wrapper funcional para consultas rápidas al CLI de IA

### Autenticación Manual Post-Instalación

- OAuth2 automático deshabilitado para evitar prompts interactivos
- Autenticación manual requerida post-instalación:
  - login OAuth del CLI de IA (retirado en v0.2.0)
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
- Guía del CLI de IA creada (retirada en v0.2.0, ver AGENTS.md).
- README actualizado con enlaces a docs y regla de mantener PROGRESS.md.
- ROADMAP actualizado: AGENTS.md marcado como completado.
### Corrección de CI - Módulo SSH
- **Fallo en test SSH resuelto**: Corregido path relativo en test_ssh_module.bats causando que lint.sh no encontrara el archivo, y advertencia SC2088 en test-installation.sh cambiando ~ por $HOME.

## 2025-12-28 (v2025-09-25.1b42acb)

### Integración de Ramas y Mejoras en Instalador

- **Integración de ramas**: Unificado `feature/windows-nvim-install`, `feature/hexagonal-validate` y `pr-3` en `main`.
- **Módulo 07-local-ssh-server.sh mejorado**:
  - Fusionado enfoque modular con helper scripts (`ssh-local-start` etc.) de la rama windows.
  - Mantenido logging en español y estructura robusta de `main`.
  - Soporte mejorado para configuración automática y helpers en PATH.
- **Validación Final Incorporada**:
  - `setup.sh` ahora incluye paso de validación final con `scripts/validate-agents.sh`.
  - Fix: Uso de rutas absolutas (`$SCRIPT_DIR`) para evitar error "No such file".
- **Tests**:
  - Unificada lógica de `lint_check` en `tests/bats/test_helper.bash`.
