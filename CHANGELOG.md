# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-11-03

### Added

- **Interactive installer.** `bash setup.sh` now opens a component menu with four groups
  (Base system, Shell + editor, AI CLIs, SSH) and a per-CLI sub-menu for the AI group.
  Toggle with `1-4`, `a` = all, `n` = none, `d` = install, `q` = quit.
- **Five AI CLIs** installed by `modules/03-ai-integration.sh`, one idempotent function each:
  `claude` (`@anthropic-ai/claude-code`), `opencode` (`opencode-ai`), `codex` (`@openai/codex`),
  `wrangler` (`wrangler`) and `agy` (Google Antigravity, manual download).
- Non-interactive overrides: `--components=claude,opencode,codex` and `--no-menu`.
- `TERMUX_AI_COMPONENTS` contract between `setup.sh` and the AI integration module.
- A component/status/version summary table at the end of the AI module.
- `CHANGELOG.md` (this file).

### Changed

- `README.md` rewritten in English: what's new, requirements, install, interactive menu,
  what gets installed, usage, troubleshooting, uninstall.
- `scripts/validate-agents.sh` validates the five CLIs; a missing `agy` is a warning, not a
  failure. Also fixed a `local` outside a function that aborted validation early.
- `scripts/verify-setup.sh`, `scripts/termux-ai-panel.sh`, `modules/test-installation.sh` and
  `modules/99-clean-reset.sh` now work with the five CLIs.
- `backend/main.py` and `web-ui/src/main.js` report `claude`, `opencode`, `codex`, `wrangler`
  and `agy` (detected with `shutil.which`).
- Neovim config: the AI plugin set targets the CLIs that actually exist; `claude-code.nvim` is
  enabled and the other agents are documented as terminal-first tools.
- The `g` shell helper runs `opencode run` and documents how to repoint it.
- `package.json` version bumped to `0.2.0`; project description updated.

### Removed

- **The Google Gemini CLI.** It no longer exists, so every reference, installer, check, panel
  entry, endpoint and document was removed, and `GEMINI.md` was deleted. This is a breaking
  change for anyone relying on the old `gemini` install path.

[0.2.0]: https://github.com/iberi22/termux-dev-nvim-agents/releases/tag/v0.2.0
