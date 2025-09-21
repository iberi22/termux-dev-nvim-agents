#!/usr/bin/env bash
set -euo pipefail

# ====================================
# MODULE: Nerd Fonts Setup for Termux
# Installs popular Nerd Fonts and sets default terminal font
# Default: FiraCode Nerd Font Mono
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

# Top 10 popular Nerd Fonts (Mono variants preferred for terminals)
NF_BASE="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
declare -A FONTS=([
  FiraCode]=FiraCode [JetBrainsMono]=JetBrainsMono [Hack]=Hack [CascadiaCode]=CascadiaCode [SourceCodePro]=SourceCodePro \
  [Meslo]=Meslo [UbuntuMono]=UbuntuMono [Mononoki]=Mononoki [VictorMono]=VictorMono [Iosevka]=Iosevka
)

TERMUX_DIR="$HOME/.termux"
FONT_TTF="$TERMUX_DIR/font.ttf"
WORK_DIR="$(mktemp -d)"

cleanup() { rm -rf "$WORK_DIR" 2>/dev/null || true; }
trap cleanup EXIT INT TERM

ensure_tools() {
  info "Ensuring required tools (unzip, curl/wget)"
  pkg update -y >/dev/null 2>&1 || true
  pkg install -y unzip wget curl >/dev/null 2>&1 || true
  mkdir -p "$TERMUX_DIR"
}

download_and_set_font() {
  local key="$1"
  local zipName="${key}.zip"
  local url="${NF_BASE}/${key}.zip"

  info "Downloading ${key} Nerd Font from ${url}"
  if ! wget -q -O "$WORK_DIR/$zipName" "$url"; then
    err "Failed to download ${key} Nerd Font"
    return 1
  fi

  info "Unzipping ${zipName}"
  unzip -oq "$WORK_DIR/$zipName" -d "$WORK_DIR/${key}"

  # Prefer Mono Regular variant for terminal
  local ttf
  ttf="$(ls "$WORK_DIR/${key}"/*NerdFontMono-Regular.ttf 2>/dev/null | head -n1 || true)"
  if [[ -z "${ttf}" ]]; then
    # Fallback to any NerdFontMono
    ttf="$(ls "$WORK_DIR/${key}"/*NerdFontMono*.ttf 2>/dev/null | head -n1 || true)"
  fi
  if [[ -z "${ttf}" ]]; then
    # Last resort: any NerdFont .ttf
    ttf="$(ls "$WORK_DIR/${key}"/*NerdFont*.ttf 2>/dev/null | head -n1 || true)"
  fi

  if [[ -z "${ttf}" ]]; then
    err "Could not locate a suitable TTF in ${key} archive"
    return 1
  fi

  cp -f "$ttf" "$FONT_TTF"
  termux-reload-settings || true
  ok "Set Termux font to ${key} Nerd Font (Mono)"
}

show_menu() {
  echo -e "${BLUE}==> Nerd Fonts for Termux${NC}"
  echo "Select a font to install and set as default:"
  local i=1
  for key in "${!FONTS[@]}"; do
    echo "  $i) ${FONTS[$key]}"
    i=$((i+1))
  done | sort -n
  echo "  0) Cancel"
  printf "Enter choice [0-%d]: " $((i-1))
}

main() {
  ensure_tools

  local mode="${1:-default}"
  if [[ "$mode" == "default" ]]; then
    # Default to FiraCode
    download_and_set_font "FiraCode" || exit 1
    ok "Default font applied: FiraCode Nerd Font Mono"
    echo -e "${YELLOW}Tip:${NC} You can change font anytime: cd ~/termux-ai-setup && bash modules/06-fonts-setup.sh menu"
    return 0
  fi

  if [[ "$mode" == "menu" ]]; then
    show_menu
    read -r choice
    if [[ "$choice" == "0" ]]; then
      warn "Cancelled by user"
      exit 0
    fi
    local keys=("${!FONTS[@]}")
    # Keep array order deterministic
    keys=(FiraCode JetBrainsMono Hack CascadiaCode SourceCodePro Meslo UbuntuMono Mononoki VictorMono Iosevka)
    local idx=$((choice-1))
    if (( idx < 0 || idx >= ${#keys[@]} )); then
      err "Invalid selection"
      exit 1
    fi
    download_and_set_font "${keys[$idx]}" || exit 1
    ok "Font changed successfully"
    exit 0
  fi

  # If a specific key is provided
  local key="$mode"
  if [[ -n "${FONTS[$key]:-}" ]]; then
    download_and_set_font "$key" || exit 1
  else
    err "Unknown font key: $key"
    echo "Available: FiraCode JetBrainsMono Hack CascadiaCode SourceCodePro Meslo UbuntuMono Mononoki VictorMono Iosevka"
    exit 1
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
