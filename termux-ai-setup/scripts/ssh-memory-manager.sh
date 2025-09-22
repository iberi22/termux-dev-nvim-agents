#!/data/data/com.termux/files/usr/bin/bash
# Legacy path shim. The script moved to $HOME/scripts/ssh-memory-manager.sh
if [ -f "$HOME/scripts/ssh-memory-manager.sh" ]; then
  exec "$HOME/scripts/ssh-memory-manager.sh" "$@"
else
  echo "ssh-memory-manager has moved to: $HOME/scripts/ssh-memory-manager.sh"
  exit 1
fi