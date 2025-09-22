#!/bin/bash

# ====================================
# MÓDULO: Testing de Instalación
# Verifica que todos los componentes estén correctamente instalados
# ====================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🧪 Ejecutando tests de instalación...${NC}"

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Función para ejecutar test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="${3:-0}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -en "${YELLOW}🔍 Test: ${test_name}... ${NC}"

    if eval "$test_command" >/dev/null 2>&1; then
        local result=$?
        if [[ $result -eq $expected_result ]]; then
            echo -e "${GREEN}✅ PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}❌ FAILED (exit code: $result)${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "${RED}❌ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Función para test con salida
run_test_with_output() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -en "${YELLOW}🔍 Test: ${test_name}... ${NC}"

    local output
    if output=$(eval "$test_command" 2>&1); then
        if echo "$output" | grep -q "$expected_pattern"; then
            echo -e "${GREEN}✅ PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}❌ FAILED (pattern not found)${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "${RED}❌ FAILED (command failed)${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                    TESTS DE PAQUETES BÁSICOS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Tests de paquetes básicos (esenciales)
run_test "curl instalado" "command -v curl"
run_test "wget instalado" "command -v wget"
run_test "git instalado" "command -v git"
run_test "node instalado" "command -v node"
run_test "python instalado" "command -v python"

# Herramientas opcionales: no deben fallar el test global si no están
echo -en "${YELLOW}🔍 Test: ripgrep opcional... ${NC}"
if command -v rg >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PRESENTE${NC}"; TESTS_PASSED=$((TESTS_PASSED + 1));
else
    echo -e "${YELLOW}⏭️  SKIPPED${NC}";
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -en "${YELLOW}🔍 Test: fd opcional... ${NC}"
if command -v fd >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PRESENTE${NC}"; TESTS_PASSED=$((TESTS_PASSED + 1));
else
    echo -e "${YELLOW}⏭️  SKIPPED${NC}";
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -en "${YELLOW}🔍 Test: fzf opcional... ${NC}"
if command -v fzf >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PRESENTE${NC}"; TESTS_PASSED=$((TESTS_PASSED + 1));
else
    echo -e "${YELLOW}⏭️  SKIPPED${NC}";
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -en "${YELLOW}🔍 Test: lazygit opcional... ${NC}"
if command -v lazygit >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PRESENTE${NC}"; TESTS_PASSED=$((TESTS_PASSED + 1));
else
    echo -e "${YELLOW}⏭️  SKIPPED${NC}";
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                      TESTS DE ZSH${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Tests de Zsh
run_test "zsh instalado" "command -v zsh"
run_test "Oh My Zsh instalado" "test -d ~/.oh-my-zsh"
run_test "Powerlevel10k tema instalado" "test -d ~/.oh-my-zsh/custom/themes/powerlevel10k"
run_test "Plugin autosuggestions" "test -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
run_test "Plugin syntax-highlighting" "test -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
run_test "Archivo .zshrc existe" "test -f ~/.zshrc"

# Test de configuración en .zshrc
if [[ -f ~/.zshrc ]]; then
    run_test_with_output "Powerlevel10k en .zshrc" "cat ~/.zshrc" "powerlevel10k/powerlevel10k"
    run_test_with_output "Plugins configurados" "cat ~/.zshrc" "zsh-autosuggestions"
fi

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                     TESTS DE NEOVIM${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Tests de Neovim
run_test "nvim instalado" "command -v nvim"
run_test "Configuración nvim existe" "test -d ~/.config/nvim"
run_test "init.lua existe" "test -f ~/.config/nvim/init.lua"
run_test "Directorio lua/plugins existe" "test -d ~/.config/nvim/lua/plugins"

# Tests de archivos de configuración de Neovim
if [[ -d ~/.config/nvim/lua/plugins ]]; then
    run_test "Plugin UI configurado" "test -f ~/.config/nvim/lua/plugins/ui.lua"
    run_test "Plugin Explorer configurado" "test -f ~/.config/nvim/lua/plugins/explorer.lua"
    run_test "Plugin Telescope configurado" "test -f ~/.config/nvim/lua/plugins/telescope.lua"
    run_test "Plugin LSP configurado" "test -f ~/.config/nvim/lua/plugins/lsp.lua"
    run_test "Plugin Treesitter configurado" "test -f ~/.config/nvim/lua/plugins/treesitter.lua"
    run_test "Plugin AI configurado" "test -f ~/.config/nvim/lua/plugins/ai.lua"
    run_test "Plugin Dev-tools configurado" "test -f ~/.config/nvim/lua/plugins/dev-tools.lua"
fi

# Test básico de Neovim
run_test_with_output "Neovim versión" "nvim --version" "NVIM v"

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                   TESTS DE INTEGRACIÓN IA${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Tests de integración IA (scripts)
run_test "Directorio bin existe" "test -d ~/bin"
run_test "Script ai-code-review" "test -f ~/bin/ai-code-review"
run_test "Script ai-generate-docs" "test -f ~/bin/ai-generate-docs"
run_test "Script ai-project-analysis" "test -f ~/bin/ai-project-analysis"
run_test "Script ai-help" "test -f ~/bin/ai-help"

# Test de permisos ejecutables
run_test "ai-code-review ejecutable" "test -x ~/bin/ai-code-review"
run_test "ai-generate-docs ejecutable" "test -x ~/bin/ai-generate-docs"
run_test "ai-project-analysis ejecutable" "test -x ~/bin/ai-project-analysis"
run_test "ai-help ejecutable" "test -x ~/bin/ai-help"

# Test de variable de entorno PATH
run_test_with_output "~/bin en PATH" "echo \$PATH" "/bin"

# Tests de CLIs IA instalados con npm
echo -en "${YELLOW}🔍 Test: Codex CLI (codex)... ${NC}"
if command -v codex >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PRESENTE${NC}"; TESTS_PASSED=$((TESTS_PASSED + 1));
else
    echo -e "${YELLOW}⏭️  SKIPPED (no instalado)${NC}";
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -en "${YELLOW}🔍 Test: Gemini CLI (gemini)... ${NC}"
if command -v gemini >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PRESENTE${NC}"; TESTS_PASSED=$((TESTS_PASSED + 1));
else
    echo -e "${YELLOW}⏭️  SKIPPED (no instalado)${NC}";
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -en "${YELLOW}🔍 Test: Qwen CLI (qwen/qwen-code)... ${NC}"
if command -v qwen >/dev/null 2>&1 || command -v qwen-code >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PRESENTE${NC}"; TESTS_PASSED=$((TESTS_PASSED + 1));
else
    echo -e "${YELLOW}⏭️  SKIPPED (no instalado)${NC}";
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                   TESTS DE WORKFLOWS IA${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Tests de workflows
run_test "Directorio workflows existe" "test -d ~/.config/ai-workflows"
run_test "Directorio templates existe" "test -d ~/.config/ai-workflows/templates"
run_test "Directorio agents existe" "test -d ~/.config/ai-workflows/agents"

# Tests de agentes
run_test "Agente ai-developer" "test -f ~/.config/ai-workflows/agents/ai-developer.poml"
run_test "Agente workflow-optimizer" "test -f ~/.config/ai-workflows/agents/workflow-optimizer.poml"
run_test "Agente documentation-generator" "test -f ~/.config/ai-workflows/agents/documentation-generator.poml"

# Tests de scripts de workflow
run_test "Script run-workflow" "test -f ~/.config/ai-workflows/run-workflow.sh"
run_test "run-workflow ejecutable" "test -x ~/.config/ai-workflows/run-workflow.sh"
run_test "Script ai-init-project" "test -f ~/bin/ai-init-project"
run_test "ai-init-project ejecutable" "test -x ~/bin/ai-init-project"

# Test de configuración
run_test "Configuración workflows" "test -f ~/.config/ai-workflows/config.yaml"

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                    TESTS FUNCIONALES${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Tests funcionales básicos
echo -en "${YELLOW}🔍 Test: Git configuración usuario... ${NC}"
if git config --get user.name >/dev/null 2>&1 && git config --get user.email >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PASSED${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}❌ FAILED${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test de creación de proyecto temporal
echo -en "${YELLOW}🔍 Test: Función ai-init-project... ${NC}"
TEMP_PROJECT_DIR="/tmp/test-ai-project-$$"
if ~/bin/ai-init-project "test-project" "$TEMP_PROJECT_DIR" >/dev/null 2>&1; then
    if [[ -f "$TEMP_PROJECT_DIR/README.md" && -d "$TEMP_PROJECT_DIR/.ai" ]]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        rm -rf "$TEMP_PROJECT_DIR" 2>/dev/null || true
    else
        echo -e "${RED}❌ FAILED (files not created)${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo -e "${RED}❌ FAILED (script error)${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test de workflow runner
echo -en "${YELLOW}🔍 Test: run-workflow.sh help... ${NC}"
if ~/.config/ai-workflows/run-workflow.sh >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PASSED${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}❌ FAILED${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                   RESUMEN DE TESTS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${BLUE}📊 Total de tests ejecutados: ${TOTAL_TESTS}${NC}"
echo -e "${GREEN}✅ Tests exitosos: ${TESTS_PASSED}${NC}"
echo -e "${RED}❌ Tests fallidos: ${TESTS_FAILED}${NC}"

# Calcular porcentaje de éxito
if [[ $TOTAL_TESTS -gt 0 ]]; then
    success_rate=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${CYAN}📈 Tasa de éxito: ${success_rate}%${NC}"

    if [[ $success_rate -ge 90 ]]; then
        echo -e "\n${GREEN}🎉 ¡EXCELENTE! La instalación está funcionando correctamente${NC}"
        exit_code=0
    elif [[ $success_rate -ge 75 ]]; then
        echo -e "\n${YELLOW}⚠️ BUENO: La mayoría de componentes funcionan, pero hay algunos problemas menores${NC}"
        exit_code=0
    elif [[ $success_rate -ge 50 ]]; then
        echo -e "\n${YELLOW}⚠️ REGULAR: Hay varios problemas que necesitan atención${NC}"
        exit_code=1
    else
        echo -e "\n${RED}❌ CRÍTICO: Muchos componentes no están funcionando correctamente${NC}"
        exit_code=1
    fi
else
    echo -e "\n${RED}❌ ERROR: No se pudieron ejecutar los tests${NC}"
    exit_code=1
fi

echo -e "\n${CYAN}💡 RECOMENDACIONES:${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${YELLOW}• Revisa los componentes que fallaron${NC}"
    echo -e "${YELLOW}• Ejecuta los módulos específicos para reinstalar${NC}"
    echo -e "${YELLOW}• Verifica la configuración de API keys si hay errores de IA${NC}"
    echo -e "${YELLOW}• Consulta los logs en ~/.termux-dev-nvim-agents/logs/${NC}"
fi

echo -e "${CYAN}• Usa 'run-workflow.sh' para workflows de IA${NC}"
echo -e "${CYAN}• Usa 'ai-init-project' para crear nuevos proyectos${NC}"
echo -e "${CYAN}• Usa los scripts ai-* para asistencia de desarrollo${NC}"

echo -e "\n${PURPLE}🎯 Testing completado${NC}"

exit $exit_code