#!/usr/bin/env bash
set -euo pipefail

# Module: Workflows Setup
# Purpose: Prepare GitHub Actions workflows and related CI helpers

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${BLUE}ℹ️  $*${NC}"; }
ok()    { echo -e "${GREEN}✅ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠️  $*${NC}"; }

ensure_workflows() {
  info "Validando workflows de GitHub Actions..."
  local wf_dir="$PWD/.github/workflows"
  if [[ -d "$wf_dir" ]]; then
    ok "Directorio de workflows presente: $wf_dir"
  else
    warn "Workflows no encontrados (ruta esperada: $wf_dir). Continuando..."
  fi
}

main() {
  ensure_workflows
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
