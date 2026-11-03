#!/usr/bin/env bash
set -euo pipefail

# ====================================
# MODULE: Full Clean & Reset for Termux AI Setup
# Removes configs, caches, npm global CLIs, workflows, fonts, and optional shells
# Then optionally triggers a full reinstallation.
# ====================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}➤${NC} $*"; }
ok() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }
err() { echo -e "${RED}✗${NC} $*"; }

confirm() {
  local prompt="$1"; shift || true
  read -r -p "$prompt [y/N]: " ans || true
  [[ "$ans" =~ ^[Yy]$ ]]
}

remove_path_line() {
  local file="$1"; local pattern="$2"
  [[ -f "$file" ]] || return 0
  # Remove lines containing the exact pattern safely
  sed -i "\|$pattern|d" "$file" 2>/dev/null || true
}

main() {
  echo -e "${BLUE}🧹 Limpieza total del entorno Termux AI Setup${NC}"
  echo -e "${YELLOW}Esta acción eliminará configuraciones, cachés, fuentes y CLIs de IA.${NC}"

  if ! confirm "¿Deseas continuar con la limpieza completa?"; then
    warn "Limpieza cancelada por el usuario"
    exit 0
  fi

  # 1) Neovim configs y cachés
  info "Eliminando configuración y cachés de Neovim"
  rm -rf "$HOME/.config/nvim" "$HOME/.local/share/nvim" "$HOME/.cache/nvim" 2>/dev/null || true

  # 2) Workflows de IA y binarios de usuario
  info "Eliminando workflows de IA y wrappers en ~/bin"
  rm -rf "$HOME/.config/ai-workflows" 2>/dev/null || true
  mkdir -p "$HOME/bin"
  for f in ai-code-review ai-generate-docs ai-project-analysis ai-help ai-init-project; do
    rm -f "$HOME/bin/$f" 2>/dev/null || true
  done

  # 3) CLIs de IA instalados globalmente vía npm
  if command -v npm >/dev/null 2>&1; then
    info "Desinstalando CLIs de IA globales (@anthropic-ai/claude-code, opencode-ai, @openai/codex, wrangler)"
    npm uninstall -g @anthropic-ai/claude-code >/dev/null 2>&1 || true
    npm uninstall -g opencode-ai >/dev/null 2>&1 || true
    npm uninstall -g @openai/codex >/dev/null 2>&1 || true
    npm uninstall -g wrangler >/dev/null 2>&1 || true
    npm cache clean --force >/dev/null 2>&1 || true
    # También limpiar binarios huérfanos del prefijo global
    NPM_BIN=$(npm bin -g 2>/dev/null || echo "")
    if [[ -n "$NPM_BIN" ]]; then
      rm -f "$NPM_BIN/claude" "$NPM_BIN/opencode" "$NPM_BIN/codex" "$NPM_BIN/wrangler" 2>/dev/null || true
    fi
  else
    warn "npm no está disponible; saltando desinstalación de CLIs de IA"
  fi

  # 'agy' (Google Antigravity) no se instala por npm: se avisa y se deja intacto.
  if command -v agy >/dev/null 2>&1; then
    warn "agy (Google Antigravity) se instaló manualmente y NO se elimina automáticamente."
  fi

  # 4) Fuentes de Termux
  info "Eliminando fuente personalizada de Termux"
  rm -f "$HOME/.termux/font.ttf" 2>/dev/null || true
  command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings || true

  # 5) Variables y archivos de IA
  info "Eliminando variables y archivos de entorno de IA"
  rm -f "$HOME/.ai-env" "$HOME/.ai-info" 2>/dev/null || true
  # Nota: las credenciales OAuth2 las gestiona cada CLI en su propio directorio de config.

  # 6) Zsh y Oh My Zsh (opcional)
  if confirm "¿Eliminar también configuración de Zsh y Oh My Zsh? (mantendrá Bash funcional)"; then
    info "Eliminando Zsh/Oh My Zsh"
    rm -rf "$HOME/.oh-my-zsh" "$HOME/.zshrc" "$HOME/.zshrc.backup."* 2>/dev/null || true
  else
    warn "Conservando configuración de Zsh"
  fi

  # 7) SSH (opcional)
  if confirm "¿Eliminar claves SSH en ~/.ssh? (NO recomendado si las usas para GitHub)"; then
    info "Eliminando ~/.ssh"
    rm -rf "$HOME/.ssh" 2>/dev/null || true
  else
    warn "Conservando ~/.ssh"
  fi

  # 8) Limpieza de caches comunes
  info "Eliminando caches comunes"
  rm -rf "$HOME/.cache/ai" "$HOME/.cache/claude" "$HOME/.cache/opencode" \
         "$HOME/.cache/codex" "$HOME/.cache/wrangler" 2>/dev/null || true

  ok "Limpieza completada"

  # 9) Ofrecer reinstalación inmediata
  if confirm "¿Deseas iniciar una reinstalación completa ahora?"; then
    # Llamar al instalador principal si está disponible
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SETUP_SCRIPT="${SCRIPT_DIR}/../setup.sh"

    if [[ -f "$SETUP_SCRIPT" ]]; then
      info "Iniciando reinstalación automática"
      bash "$SETUP_SCRIPT" auto || true
    elif [[ -f "$HOME/termux-ai-setup/setup.sh" ]]; then
      success "Found installer in $HOME/termux-ai-setup"
      bash "$HOME/termux-ai-setup/setup.sh" auto || true
    else
      warn "  cd ~/termux-ai-setup && ./setup.sh auto"
      warn "Or run installer again:"
      warn "  wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash"
    fi
  else
    info "Puedes reinstalar más tarde ejecutando:"
    info "  cd ~/termux-ai-setup && ./setup.sh auto"
  fi
}

main "$@"
