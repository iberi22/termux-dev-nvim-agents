#!/bin/bash

# ====================================
# MODULE: System Optimization for Termux
# Configuración de permisos, optimización de rendimiento
# ====================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Optimizando sistema Termux...${NC}"

# Función para solicitar permisos de almacenamiento
request_storage_permissions() {
    echo -e "${BLUE}📱 Solicitando permisos de almacenamiento...${NC}"
    
    # Solicitar permisos de almacenamiento si no están concedidos
    if [[ ! -d "$HOME/storage" ]]; then
        echo -e "${YELLOW}⚠️ Permisos de almacenamiento requeridos${NC}"
        if [[ "${TERMUX_AI_AUTO:-}" == "1" ]]; then
            echo -e "${CYAN}🤖 Modo automático: configurando automáticamente${NC}"
            # Try multiple times with timeout
            timeout 10 termux-setup-storage || true
            sleep 3
            # If still not working, create a placeholder
            if [[ ! -d "$HOME/storage" ]]; then
                mkdir -p "$HOME/storage/shared" 2>/dev/null || true
                echo -e "${YELLOW}⚠️ Permisos de almacenamiento pueden requerir configuración manual${NC}"
            fi
        else
            echo -e "${CYAN}Por favor, concede permisos de almacenamiento cuando se soliciten${NC}"
            timeout 30 termux-setup-storage || {
                echo -e "${YELLOW}⚠️ Timeout en permisos de almacenamiento${NC}"
            }
        fi
    else
        echo -e "${GREEN}✅ Permisos de almacenamiento ya concedidos${NC}"
    fi
}# Función para configurar Termux como servicio real
setup_termux_service() {
    echo -e "${BLUE}🔧 Configurando Termux como servicio real...${NC}"

    # Instalar termux-services si no está instalado
    if ! pkg list-installed | grep -q termux-services; then
        echo -e "${YELLOW}📦 Instalando termux-services...${NC}"
        pkg install -y termux-services >/dev/null 2>&1
    fi

    # Configurar servicios para inicio automático
    mkdir -p "$HOME/.termux/boot"

    # Script de inicio automático
    cat > "$HOME/.termux/boot/startup.sh" << 'EOF'
#!/bin/bash
# Auto-start services on Termux boot

# Configurar prioridad de procesos
if command -v renice >/dev/null 2>&1; then
    renice -n -10 -p $$ 2>/dev/null || true
fi

# Configurar límites de memoria
ulimit -v unlimited 2>/dev/null || true
ulimit -m unlimited 2>/dev/null || true

# Iniciar SSH server si está configurado
if command -v sshd >/dev/null 2>&1 && [[ -f "$HOME/.ssh/authorized_keys" || -f "/data/data/com.termux/files/usr/etc/ssh/sshd_config" ]]; then
    sshd -D -p 8022 &
fi

# Optimizaciones del sistema
export TMPDIR="$HOME/.cache/tmp"
mkdir -p "$TMPDIR"
EOF

    chmod +x "$HOME/.termux/boot/startup.sh"
    echo -e "${GREEN}✅ Termux configurado como servicio${NC}"
}

# Función para optimizar prioridad de CPU y memoria
optimize_performance() {
    echo -e "${BLUE}⚡ Optimizando rendimiento del sistema...${NC}"

    # Configurar variables de entorno para optimización
    cat >> "$HOME/.bashrc" << 'EOF'

# === OPTIMIZACIONES DE TERMUX AI ===
export TMPDIR="$HOME/.cache/tmp"
export TEMP="$TMPDIR"
export TMP="$TMPDIR"
mkdir -p "$TMPDIR"

# Optimizaciones de rendimiento
export NODE_OPTIONS="--max-old-space-size=4096"
export PYTHON_OPTIMIZE=1
export PYTHONDONTWRITEBYTECODE=1

# Configurar límites de recursos
ulimit -n 4096 2>/dev/null || true
ulimit -u 4096 2>/dev/null || true

# Configurar prioridad alta para procesos críticos
if command -v renice >/dev/null 2>&1; then
    renice -n -5 -p $$ 2>/dev/null || true
fi
EOF

    # Crear directorio de cache optimizado
    mkdir -p "$HOME/.cache/tmp"
    mkdir -p "$HOME/.cache/npm"
    mkdir -p "$HOME/.cache/pip"

    # Configurar npm para usar cache local
    if command -v npm >/dev/null 2>&1; then
        npm config set cache "$HOME/.cache/npm" --global 2>/dev/null || true
        npm config set prefer-offline true --global 2>/dev/null || true
    fi

    # Configurar pip para usar cache local
    mkdir -p "$HOME/.config/pip"
    cat > "$HOME/.config/pip/pip.conf" << 'EOF'
[global]
cache-dir = /data/data/com.termux/files/home/.cache/pip
trusted-host = pypi.org
               pypi.python.org
               files.pythonhosted.org
EOF

    echo -e "${GREEN}✅ Optimizaciones de rendimiento aplicadas${NC}"
}

# Función para configurar wake locks (mantener CPU activa)
setup_wake_locks() {
    echo -e "${BLUE}🔋 Configurando wake locks para estabilidad...${NC}"

    # Instalar termux-api si no está instalado
    if ! pkg list-installed | grep -q termux-api; then
        echo -e "${YELLOW}📦 Instalando termux-api...${NC}"
        pkg install -y termux-api >/dev/null 2>&1
    fi

    # Script para mantener CPU activa durante operaciones críticas
    cat > "$HOME/bin/wake-lock" << 'EOF'
#!/bin/bash
# Script para mantener CPU activa durante operaciones largas

if command -v termux-wake-lock >/dev/null 2>&1; then
    termux-wake-lock
    echo "Wake lock activado"

    # Ejecutar comando con wake lock
    if [[ $# -gt 0 ]]; then
        "$@"
        termux-wake-unlock
        echo "Wake lock desactivado"
    else
        echo "Mantén la CPU activa. Ejecuta 'termux-wake-unlock' para liberar."
    fi
else
    echo "termux-api no disponible"
    # Ejecutar comando sin wake lock
    if [[ $# -gt 0 ]]; then
        "$@"
    fi
fi
EOF

    mkdir -p "$HOME/bin"
    chmod +x "$HOME/bin/wake-lock"

    echo -e "${GREEN}✅ Wake locks configurados${NC}"
}

# Función para optimizar configuración de red
optimize_network() {
    echo -e "${BLUE}🌐 Optimizando configuración de red...${NC}"

    # Configurar DNS confiables
    cat > "$PREFIX/etc/resolv.conf" << 'EOF'
# Optimized DNS configuration for Termux
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

    # Configurar timeout más rápido para conexiones
    cat >> "$HOME/.bashrc" << 'EOF'

# Optimizaciones de red
export CONNECT_TIMEOUT=10
export READ_TIMEOUT=30
export CURL_CA_BUNDLE="$PREFIX/etc/tls/cert.pem"
EOF

    echo -e "${GREEN}✅ Red optimizada${NC}"
}

# Función para configurar logging optimizado
setup_logging() {
    echo -e "${BLUE}📝 Configurando logging optimizado...${NC}"

    mkdir -p "$HOME/.logs"

    # Configurar rotación de logs
    cat > "$HOME/.logs/cleanup.sh" << 'EOF'
#!/bin/bash
# Limpiar logs antiguos automáticamente
find "$HOME/.logs" -name "*.log" -mtime +7 -delete 2>/dev/null || true
find "$HOME/.cache" -name "*.log" -mtime +3 -delete 2>/dev/null || true
EOF

    chmod +x "$HOME/.logs/cleanup.sh"

    # Agregar limpieza automática al cron o startup
    echo "$HOME/.logs/cleanup.sh" >> "$HOME/.termux/boot/startup.sh"

    echo -e "${GREEN}✅ Logging configurado${NC}"
}

# Función principal
main() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│           OPTIMIZACIÓN DEL SISTEMA              │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"

    request_storage_permissions
    setup_termux_service
    optimize_performance
    setup_wake_locks
    optimize_network
    setup_logging

    echo -e "\n${GREEN}🎉 Optimización del sistema completada${NC}"
    echo -e "${YELLOW}💡 Reinicia Termux para aplicar todas las optimizaciones${NC}"

    # Aplicar configuraciones inmediatamente
    source "$HOME/.bashrc" 2>/dev/null || true
}

# Ejecutar optimizaciones
main "$@"