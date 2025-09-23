#!/bin/bash

# ====================================
# COMANDO ":" - Activador del Agente IA
# Uso: : "tu pregunta aquí"
# ====================================

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Localizar el agente
AGENT_SCRIPT=""
if [[ -f "${SCRIPT_DIR}/termux-ai-agent.sh" ]]; then
    AGENT_SCRIPT="${SCRIPT_DIR}/termux-ai-agent.sh"
elif [[ -f ~/bin/termux-ai-agent ]]; then
    AGENT_SCRIPT=~/bin/termux-ai-agent
elif [[ -x "$(which termux-ai-agent 2>/dev/null)" ]]; then
    AGENT_SCRIPT="$(which termux-ai-agent)"
else
    echo "❌ Error: Agente IA no encontrado"
    echo "💡 Ejecuta el instalador para configurar el sistema"
    exit 1
fi

# Ejecutar el agente con todos los argumentos
exec "$AGENT_SCRIPT" "$@"