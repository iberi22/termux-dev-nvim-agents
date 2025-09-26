# Task List (Spec-Driven)

*Tareas derivadas del [ROADMAP.md](./ROADMAP.md) - cada nueva tarea debe referenciar su fase correspondiente*

## Backlog

### Phase 3: Panel y Utilidades (del ROADMAP)

- [ ] **ROADMAP-P3.1**: Panel: detectar repos en ~/src/*, mostrar rama y cambios
- [ ] **ROADMAP-P3.2**: Panel: acción para `git pull`/`git push` por repo
- [ ] **ROADMAP-P3.3**: Panel: iniciar servidor HTTP estático en puerto 9999
- [ ] **ROADMAP-P3.4**: Panel: opción para pruebas rápidas de puertos/servicios
- [ ] **ROADMAP-P3.5**: Setup automático de `~/src` y plantillas de repos

### Phase 4: UI Web + Backend (del ROADMAP)

- [ ] **ROADMAP-P4.1**: UI Web: bootstrap Vite + Tailwind (plantilla SPA)
- [ ] **ROADMAP-P4.2**: Backend: FastAPI scaffolding + WebSockets echo
- [ ] **ROADMAP-P4.3**: Integración panel→UI (abrir en localhost:9999)

### Phase 5: Integraciones IA (del ROADMAP)

- [ ] **ROADMAP-P5.1**: Extender prompts del agente para tareas del panel

## In Progress

- [ ] **MAINT-1**: Panel utilidades ampliadas (inspección servicios)
- [ ] **DOCS-1**: Actualizar documentación post-refactoring

## Done

### Phase 1-2: Base (completadas)

- [x] **ROADMAP-P1.1**: Migración completa a OAuth2 (Gemini CLI oficial)
- [x] **ROADMAP-P1.2**: Agente `:` headless (gemini-2.5-flash)
- [x] **ROADMAP-P1.3**: Noninteractive apt/dpkg
- [x] **ROADMAP-P1.4**: Verbose, logs a ~/termux-setup.log
- [x] **ROADMAP-P2.1**: SSH keys, passwd, sshd permanente (prompt final)
- [x] **ROADMAP-P2.2**: termux-ai-panel comando

### Mantenimiento

- [x] **MAINT-REFACTOR**: Refactoring completo spec-kit minimalista (2025-09-25)
- [x] **MAINT-LEGACY**: Eliminación código rastafari y archivos duplicados
