# Termux Dev + Neovim + AI Agents

An interactive Termux installer that turns an Android phone into a full AI-assisted development
environment: zsh, Neovim, an SSH server and five CLI agents.

[![CI](https://github.com/iberi22/termux-dev-nvim-agents/actions/workflows/ci.yml/badge.svg)](https://github.com/iberi22/termux-dev-nvim-agents/actions/workflows/ci.yml)

## What's new in v0.2.0

- **Interactive component selection.** `bash setup.sh` now opens a menu where you pick which
  groups to install and, inside the AI group, which CLI agents you actually want.
- **Gemini CLI removed.** The Google Gemini CLI no longer exists, so the installer no longer
  references, installs or configures it anywhere.
- **Five CLIs instead of one agent.** `claude`, `opencode`, `codex`, `wrangler` and `agy`
  (Google Antigravity, installed manually — see below).
- **No forced installs any more.** Nothing is installed behind your back: every CLI is opt-in,
  and an agent you do not select is simply not touched.

## Requirements

- **Termux from F-Droid**, not from the Play Store. The Play Store build is abandoned and pulls
  in incompatible package paths.
- **Android 7.0 (API 24) or newer.**
- **About 2 GB of free storage** for Termux packages, Node.js, Neovim and the npm CLIs.
- A working internet connection during installation.
- Node.js 22+ is recommended if you plan to use `wrangler`.

## Install

One-liner (clones the repo, installs everything, no questions asked):

```bash
curl -L https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

> Piping into `bash` means stdin is not a terminal, so the interactive menu is skipped and
> **everything** is installed. That is intentional: it keeps the one-liner usable for automation.

To get the menu, clone the repository and run the setup script directly:

```bash
git clone https://github.com/iberi22/termux-dev-nvim-agents.git
cd termux-dev-nvim-agents
bash setup.sh
```

Non-interactive automation is also supported:

```bash
bash setup.sh --components=claude,opencode,codex   # pick the CLIs, no menu
bash setup.sh auto --no-menu                       # full install, fully unattended
```

## Interactive menu

Running `bash setup.sh` and choosing *Full installation* opens the component menu:

| Key | Group | Modules |
|-----|-------|---------|
| `1` | Base system (always on) | `00-user-input`, `00-network-fixes`, `00-fix-conflicts`, `00-system-optimization`, `00-base-packages` |
| `2` | Shell + editor | `01-zsh-setup`, `02-neovim-setup`, `06-fonts-setup` |
| `3` | AI CLIs | `03-ai-integration` (then a sub-menu per CLI) |
| `4` | SSH | `07-local-ssh-server`, `05-ssh-setup` |

Commands: a number toggles that group, `a` selects everything, `n` clears everything (the base
system stays on), `d` installs what is selected, `q` quits without installing anything.

Group 3 opens a second menu for the individual agents:

| Key | Agent | What it is |
|-----|-------|------------|
| `1` | `claude` | Anthropic Claude Code, the official agentic coding CLI |
| `2` | `opencode` | Provider-agnostic agent (DeepSeek, GLM, free models, local providers) |
| `3` | `codex` | OpenAI Codex CLI |
| `4` | `wrangler` | Cloudflare developer CLI — not an agent, but part of the toolchain |
| `5` | `agy` | Google Antigravity. **No npm package**: you must download it from <https://antigravity.google> |

Selecting nothing beyond the base system is valid: the installer runs the base modules only and
finishes successfully.

## What gets installed

| Group | Component | Source | Verify with |
|-------|-----------|--------|-------------|
| Base | Git, Node.js, npm, Python, build tools | `pkg` | `git --version`, `node --version` |
| Base | Termux tweaks, network fixes, conflict cleanup | local scripts | — |
| Shell | Zsh + Oh My Zsh + prompt theme | `pkg` / upstream | `zsh --version` |
| Editor | Neovim + Lua config (LSP, Telescope, AI plugins) | `pkg` + repo config | `nvim --version` |
| Editor | FiraCode Nerd Font | repo assets | `ls ~/.termux/font.ttf` |
| AI | `claude` | `@anthropic-ai/claude-code` | `claude --version` |
| AI | `opencode` | `opencode-ai` | `opencode --version` |
| AI | `codex` | `@openai/codex` | `codex --version` |
| AI | `wrangler` | `wrangler` | `wrangler --version` |
| AI | `agy` | manual download | `agy --version` |
| SSH | OpenSSH server + helper scripts | `pkg` | `ssh -V` |
| SSH | GitHub keys and `~/.ssh/config` | repository helpers | `ssh -T git@github.com` |

Every npm-backed CLI is idempotent: if the binary already exists it is reported with its version
and left alone.

## Usage

```bash
# Anthropic Claude Code — interactive session in the current directory
claude

# OpenCode — pipe a single task and exit
opencode run "explain the function in server.go"

# OpenAI Codex
codex

# Cloudflare Wrangler — check who you are authenticated as
wrangler whoami

# Google Antigravity (after the manual install)
agy
```

A convenience shell function is installed for quick one-shot prompts:

```bash
g "resize the PNGs in this folder"
```

`g` runs `opencode run`, so it uses whichever provider you configured for OpenCode. It is a plain
function in `config/zsh/functions.zsh`: repoint it to `claude`, `codex` or anything else by editing
that file.

## Troubleshooting

**`npm install -g` fails with EACCES on the global prefix**

Termux prefixes are per-user, so this usually means npm is pointing at a read-only location.
Reset the prefix and retry:

```bash
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"   # add this to ~/.zshrc to make it permanent
```

**A CLI installs but the binary is not found**

The npm global prefix is not on your `PATH`. Add `$HOME/.npm-global/bin` (or whatever
`npm config get prefix` prints, plus `/bin`) to `PATH` and open a new shell.

**node-gyp build errors while installing a CLI**

Termux has no Android NDK wired into Node.js. The installer exports
`GYP_DEFINES="android_ndk_path=/dev/null"` before every npm install to make packages skip the
native build. If you install a package by hand, do the same:

```bash
export GYP_DEFINES="android_ndk_path=/dev/null"
npm install -g <package>
```

**`wrangler` refuses to start**

Wrangler requires Node.js 22 or newer. Check with `node --version`; if it is older, update with
`pkg upgrade nodejs`, or install `nodejs-lts`.

**`agy` is missing after the install**

That is expected. Google Antigravity is not published on npm, so the installer only reports it.
Download it from <https://antigravity.google>, install it, and re-run `scripts/validate-agents.sh`
to confirm. A missing `agy` is a warning, never a failure.

**Can I see the installer logs?**

Yes: `~/termux-ai-setup/setup.log` and the legacy `setup.log` in the repository root.

## Uninstall

Full reset — removes Neovim config, AI workflows, the five CLIs, fonts and optionally zsh and SSH:

```bash
bash modules/99-clean-reset.sh
```

The script asks before every destructive step, and offers to reinstall when it is done.

## License

MIT License with Non-Commercial Restriction. See [LICENSE](./LICENSE) for the exact terms.
