#!/usr/bin/env bash
set -euo pipefail

echo "[smoke] Checking required files..."
for f in \
  install.sh \
  setup.sh \
  diagnose.sh \
  modules/07-local-ssh-server.sh \
  modules/00-base-packages.sh \
  modules/01-zsh-setup.sh \
  modules/02-neovim-setup.sh \
  modules/03-ai-integration.sh \
  modules/04-workflows-setup.sh \
  modules/05-ssh-setup.sh \
  modules/06-fonts-setup.sh; do
  [ -f "$(dirname "$0")/../$f" ] || { echo "Missing: $f"; exit 1; }
done

echo "[smoke] Syntax check on key scripts..."
bash -n "$(dirname "$0")/../setup.sh"
bash -n "$(dirname "$0")/../modules/07-local-ssh-server.sh"

echo "[smoke] Check executability..."
chmod +x "$(dirname "$0")/../setup.sh" || true
chmod +x "$(dirname "$0")/../modules/07-local-ssh-server.sh" || true

echo "[smoke] Verify README mentions SSH helpers..."
grep -q "ssh-local-info" "$(dirname "$0")/../README.md"

echo "[smoke] OK"
