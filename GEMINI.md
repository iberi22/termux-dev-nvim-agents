# 🧠 Guía de Gemini CLI (OAuth2)

Esta guía explica cómo usar Gemini CLI con OAuth2 (sin API keys) en este proyecto: instalación, autenticación, modelos, configuración y uso headless.

## Requisitos

- Node.js 20 o superior
- macOS/Linux/Windows (Termux soportado)

## Instalación

- Global (recomendado):
  - `npm install -g @google/gemini-cli`
- Alternativas:
  - `npx https://github.com/google-gemini/gemini-cli`
  - Homebrew: `brew install gemini-cli` (macOS/Linux)

Referencias:

- NPM: [@google/gemini-cli](https://www.npmjs.com/package/@google/gemini-cli)
- README y docs: [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli)

## Autenticación (OAuth2)

- Flujo recomendado: Login con Google (OAuth). No uses `GEMINI_API_KEY` aquí.
- Pasos:
  1. Ejecuta `gemini` y elige “Login with Google”, o usa `gemini auth login` si está disponible.
  2. Completa el login en el navegador y vuelve a la terminal.
  3. Verifica: `gemini auth test`.
- Workspace/Enterprise: si tienes licencia Code Assist o cuentas workspace, define `GOOGLE_CLOUD_PROJECT` según la guía oficial.
- Documentación de autenticación: [authentication.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/authentication.md)

## Modelos y parámetros clave

- Selección rápida de modelo: `-m` o `--model`.
  - Ejemplo: `gemini -m gemini-2.5-flash`
- Recomendación del proyecto: `gemini-2.5-flash` (rápido). Cambiable por CLI o configuración.
- Otros flags útiles:
  - `-p, --prompt`: modo no interactivo (headless).
  - `--output-format json`: salida estructurada para scripts.
  - `--include-directories`: añadir contexto de carpetas.
- Referencia de argumentos: [configuration.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/configuration.md#command-line-arguments)

## Configuración persistente (`~/.gemini/settings.json`)

Puedes fijar el modelo por defecto y otras opciones. Ejemplo mínimo:

```json
{
  "model": {
    "name": "gemini-2.5-flash"
  }
}
```

- Rutas de settings y precedencia: ver [configuration.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/configuration.md#settings-files)
- Variables de entorno relevantes (no usar API key aquí): `GEMINI_MODEL` para override temporal del modelo, `GOOGLE_CLOUD_PROJECT` si aplica.

## Uso interactivo vs headless

- Interactivo: `gemini` abre la TUI del CLI con herramientas integradas (/help, /tools, @file, !shell, etc.).
- Headless (scripts/`:`):
  - Directo: `gemini -p "Explica este repo" -m gemini-2.5-flash`
  - Atajo del proyecto: `: "tu pregunta"` (usa el modelo configurado).

## Integración con este proyecto

- Instalación y login se automatizan en `quick-setup.sh` (OAuth2). Si falla, ejecuta manualmente `gemini auth login`.
- El comando `:` usa Gemini en modo no interactivo; si no estás autenticado, se te indicará cómo hacerlo.
- Neovim: integrada la extensión `gemini-cli.nvim` para comandos `:Gemini` y `:GeminiChat` (usa el binario del sistema y OAuth2).

## Solución de problemas

- “Gemini no autenticado”:
  - Ejecuta `gemini auth login` y valida con `gemini auth test`.
- “Node.js no encontrado”:
  - Instala Node.js 20+ e intenta de nuevo la instalación del CLI.
- “Errores dpkg/openssl.cnf en Termux”:
  - El instalador ya usa modo no interactivo y opciones de `dpkg` para evitar prompts. Reintenta con `--verbose` para logs.
- “Permisos /tmp en Termux”:
  - Este proyecto redirige a `$HOME/.cache`. Verifica espacio disponible.

## Enlaces útiles

- Documentación CLI:
  - Autenticación: [authentication.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/authentication.md)
  - Comandos: [commands.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/commands.md)
  - Configuración: [configuration.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/configuration.md)
  - Quickstart: [index.md](https://raw.githubusercontent.com/google-gemini/gemini-cli/HEAD/docs/cli/index.md)
- Modelos de la API: [ai.google.dev/gemini-api/docs/models](https://ai.google.dev/gemini-api/docs/models)

## Política del proyecto

- Solo OAuth2 para Gemini. No se admiten API keys.
- Cada cambio que afecte a Gemini debe registrarse en `specs/PROGRESS.md`.
