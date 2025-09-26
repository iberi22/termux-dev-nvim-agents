#!/usr/bin/env bash
set -euo pipefail

echo "[smoke] Checking required files..."
# This list is updated to reflect the new modular architecture.
for f in \
  install.sh \
  setup.sh \
  scripts/helpers.sh \
  modules/00-user-input.sh \
  modules/00-base-packages.sh \
  modules/01-zsh-setup.sh \
  modules/02-neovim-setup.sh \
  modules/03-ai-integration.sh \
  modules/05-ssh-setup.sh \
  modules/06-fonts-setup.sh \
  modules/07-local-ssh-server.sh; do
  [ -f "$(dirname "$0")/../$f" ] || { echo "Missing required file: $f"; exit 1; }
done
echo "[smoke] All required files are present."

echo "[smoke] Syntax check on key scripts..."
bash -n "$(dirname "$0")/../setup.sh"
bash -n "$(dirname "$0")/../install.sh"
for module in modules/*.sh; do
    echo "[smoke] Syntax check for $module..."
    bash -n "$(dirname "$0")/../$module"
done
echo "[smoke] Syntax checks passed."


echo "[smoke] Verify README mentions SSH helpers..."
if ! grep -q "ssh-local-info" "$(dirname "$0")/../README.md"; then
    echo "Missing 'ssh-local-info' mention in README.md"
    exit 1
fi
echo "[smoke] README check passed."

echo "[smoke] OK"