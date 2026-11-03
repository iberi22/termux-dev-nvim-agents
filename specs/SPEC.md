# Termux AI Setup – Product Specification (Spec-Driven)

## Problem Statement

Instalar y mantener un entorno de desarrollo en Termux es lento y propenso a errores. Queremos una instalación 1‑click con agentes IA, Zsh, SSH, Node.js, y herramientas clave, con flujos sin prompts interactivos.

## Goals

- Instalación automática sin prompts (noninteractive apt/dpkg) y logs claros.
- Selección de componentes interactiva (o por flags) antes de instalar.
- Cinco CLIs de IA: `claude`, `opencode`, `codex`, `wrangler` y `agy` (manual).
- Agente IA por comando `g` (envuelve `opencode run`).
- Panel post‑instalación para estado, utilidades y servicios.
- Documentación viva basada en specs y progreso actualizado.

## Non-Goals

- No se soportan distros fuera de Termux Android por ahora.

## Personas

- Dev móvil, DevOps móvil, Estudiante.

## User Stories

- Como dev, quiero instalar todo con un comando y sin confirmar conflictos de config.
- Como dev, quiero ver la salud del entorno y mis repos rápidamente.
- Como dev, quiero habilitar SSH permanente y crear mis claves sin fricción.

## Success Criteria

- Instalación completa sin intervención; salida verbose opcional; logs en `~/termux-setup.log`.
- `g` funciona y abre agente IA; `termux-ai-panel` visible en PATH.
- Documentación minimalista spec-kit: README.md + AGENTS.md + specs/.
- README y PROGRESS actualizados en cada release.

## Implementation Status (v0.2.0)

✅ **Core completado:**

- Instalación automática con comando único, o interactiva por grupos de componentes
- Cinco CLIs de IA seleccionables: `claude`, `opencode`, `codex`, `wrangler`, `agy`
- Agente `g` headless (envuelve `opencode run`)
- Panel `termux-ai-panel` para estado del sistema, incluido el inventario de CLIs
- Documentación consolidada según spec-kit

✅ **Calidad de código:**

- Eliminado código legacy rastafari y archivos duplicados
- Scripts consolidados, mantenidos solo los esenciales
- Estructura de carpetas limpia y minimalista
