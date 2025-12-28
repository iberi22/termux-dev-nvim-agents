# Roadmap

## Phase 1: Stabilización Instalador (Done/In Progress)

- [x] Migración completa a OAuth2 (Gemini CLI oficial)
- [x] Agente `g` headless (gemini-2.5-flash)
- [x] Corrección /tmp → $HOME/.cache y TMPDIR
- [x] CI verde (BATS + ShellCheck + shfmt + LF)
- [x] Versión visible en banners/README
- [x] Verbose y logging a `~/termux-setup.log`
- [x] Noninteractive apt/dpkg y forzar `--force-confdef --force-confold`

## Phase 2: Experiencia Usuario

- [x] Preguntar `passwd` al final
- [x] Generar/mostrar SSH keys y guía GitHub
- [x] Preguntar para habilitar sshd permanente
- [x] Comando `termux-ai-panel` con health/status

## Phase 3: Panel y Utilidades

- [ ] Panel: listar proyectos en `~/src`, ramas, cambios pendientes
- [ ] Panel: iniciar servidor HTTP estático en 9999
- [ ] Panel: opción para pruebas rápidas de puertos/servicios
- [ ] Setup automático de `~/src` y plantillas de repos

## Phase 4: UI Web + Backend

- [ ] App Vite + Tailwind para UI de configuración (SPA)
- [ ] WebSockets para eventos de estado
- [ ] FastAPI backend (microservicio) para exponer API local
- [ ] Integración con panel para abrir UI (`http://localhost:9999`)

## Phase 5: Integraciones IA

- [x] AGENTS.md con agentes soportados y flujos
- [x] GEMINI.md con guías de OAuth2, modelos y agentes
- [ ] Extender prompts del agente para tareas del panel

## Phase 6: Distribución y Calidad

- [ ] Publicar versiones semánticas y CHANGELOG
- [ ] Tests E2E básicos con bats + simulación
- [ ] Telemetría opcional (opt-in) de fallos de instalación
