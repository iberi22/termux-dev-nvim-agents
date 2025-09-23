# 🤖 Agentes de IA Soportados

Este proyecto integra agentes de IA en Termux con foco en Gemini CLI (OAuth2). Otros CLIs como Codex y Qwen son opcionales. Esta guía resume capacidades, instalación y uso.

## Resumen

- Obligatorio: Google Gemini CLI (@google/gemini-cli) con autenticación OAuth2.
- Opcionales: OpenAI Codex (si está disponible) y Qwen Code. Se intentan instalar, pero no son requisito.
- Acceso rápido: usa `:` para consultas headless al modelo por defecto.

## Gemini CLI (obligatorio)

- Instalación: `npm install -g @google/gemini-cli` (Node.js >= 20 requerido).
- Autenticación: `gemini` y elige “Login with Google” (OAuth); o `gemini auth login` según flujo actual.
- Modelos: puedes fijar `-m gemini-2.5-flash` (rápido) o configurar `~/.gemini/settings.json` con `model.name`.
- Modo headless: `gemini -p "tu pregunta"` o vía nuestro wrapper `:`.
- Documentación oficial:
  - NPM: [@google/gemini-cli](https://www.npmjs.com/package/@google/gemini-cli)
  - README y docs: [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli)
  - Configuración: [configuration.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/configuration.md)
  - Autenticación: [authentication.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/authentication.md)

### Comando `:` (wrapper headless)

- Atajo del sistema que envía prompts a Gemini con el modelo por defecto.
- Si no hay login: se te pedirá ejecutar `gemini auth login`.
- Ejemplos:
  - `: "Explica cómo configurar SSH en Termux"`
  - `: "Genera un script bash para respaldo incremental"`

## OpenAI Codex (opcional)

- Intento de instalación: `@openai/codex` o `openai-codex` si existe.
- Autenticación: algunos bins ofrecen `codex login` (OAuth); puede no estar disponible.
- Uso: `codex "escribe un scraper en Python"`.

## Qwen Code (opcional)

- Paquetes candidatos: `qwen-code` o `@qwen/qwen-code`.
- Configuración: algunos exponen `qwen` o `qwen-code` con comando `setup`.
- Uso: `qwen "refactor this function"` o `qwen-code "generate unit tests"`.

## Reglas y recomendaciones

- Sin API keys para Gemini: usa únicamente OAuth2 (Login with Google). No utilices `GEMINI_API_KEY` en este proyecto.
- Actualiza PROGRESS.md: cada cambio en agentes o flujos debe registrarse.
- Versiones y modelos: preferimos `gemini-2.5-flash` por rapidez; puedes cambiarlo con `-m` o en `settings.json`.

## Solución de problemas

- Gemini no autenticado:
  - Ejecuta `gemini auth login` y valida con `gemini auth test`.
- Node.js faltante:
  - Instala Node.js 20+; en Termux usamos `apt` y ajustamos entorno.
- Errores de permisos en /tmp:
  - El proyecto ya usa `$HOME/.cache`; asegúrate de tener espacio libre.
