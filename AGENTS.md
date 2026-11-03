# 🤖 Agentes de IA Soportados

Este proyecto instala cinco CLIs en Termux: cuatro por npm (`claude`, `opencode`, `codex`,
`wrangler`) y uno de instalación manual (`agy`, Google Antigravity). No hay ningún agente
obligatorio: `setup.sh` te deja elegir cuáles quieres.

## Resumen

| key | npm package | binario | instalación |
|-----|-------------|---------|-------------|
| `claude` | `@anthropic-ai/claude-code` | `claude` | automática |
| `opencode` | `opencode-ai` | `opencode` | automática |
| `codex` | `@openai/codex` | `codex` | automática |
| `wrangler` | `wrangler` | `wrangler` | automática |
| `agy` | — (no hay paquete npm) | `agy` | **manual**: https://antigravity.google |

Selección por grupos: `bash setup.sh` abre el menú interactivo. Para automatización:

```bash
bash setup.sh --components=claude,opencode,codex   # sin menú
TERMUX_AI_COMPONENTS=claude,codex bash modules/03-ai-integration.sh   # solo el módulo
```

`TERMUX_AI_COMPONENTS` acepta una lista separada por comas o espacios, o `all`.

## Claude Code (`claude`)

- Instalación: `npm install -g @anthropic-ai/claude-code` (Node.js >= 20).
- Uso: `claude` en el directorio del proyecto.
- Integración con Neovim: plugin `greggh/claude-code.nvim` (habilitado en `config/neovim`),
  comando `:ClaudeCode`.

## OpenCode (`opencode`)

- Instalación: `npm install -g opencode-ai`.
- Uso: `opencode` (TUI) u `opencode run "tu tarea"` (un solo turno).
- Es agnóstico de proveedor: sirve para DeepSeek, GLM, modelos gratuitos y proveedores locales.
- El atajo de shell `g "tu pregunta"` apunta aquí; se puede repuntar en `config/zsh/functions.zsh`.

## OpenAI Codex (`codex`)

- Instalación: `npm install -g @openai/codex`.
- Uso: `codex` en el directorio del proyecto.

## Cloudflare Wrangler (`wrangler`)

- No es un agente, es la CLI de desarrollo de Cloudflare (Workers, Pages, KV, D1).
- Instalación: `npm install -g wrangler`. Requiere Node.js 22 o superior.
- Uso: `wrangler whoami`, `wrangler deploy`.

## Google Antigravity (`agy`)

- **No existe paquete npm.** El instalador solo lo detecta y, si falta, avisa con la URL.
- Descarga manual: https://antigravity.google
- Una ausencia de `agy` es un **warning**, nunca un fallo de instalación.
- `modules/99-clean-reset.sh` no lo desinstala: lo gestiona su propio instalador.

## Reglas y recomendaciones

- Actualiza `specs/PROGRESS.md` con cada cambio en agentes o flujos.
- Todos los instaladores son idempotentes: si el binario existe, se reporta su `--version` y no se
  reinstala nada.
- Antes de instalar por npm a mano, exporta el guard de node-gyp de Termux:
  `export GYP_DEFINES="android_ndk_path=/dev/null"`.

## Solución de problemas

- **npm EACCES en el prefijo global**: `npm config set prefix "$HOME/.npm-global"` y añade
  `$HOME/.npm-global/bin` al `PATH`.
- **El CLI se instala pero no aparece**: el prefijo global de npm no está en el `PATH`; abre una
  shell nueva.
- **`wrangler` no arranca**: necesita Node.js 22+ (`pkg upgrade nodejs`).
- **`agy` no aparece**: normal, no está en npm; descárgalo desde https://antigravity.google.
- **Node.js faltante**: el módulo `00-base-packages` lo instala, junto con npm.
- **Errores de permisos en /tmp**: el proyecto usa `$HOME/.cache`; asegúrate de tener espacio.
