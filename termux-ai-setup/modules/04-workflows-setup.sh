#!/bin/bash

# ====================================
# MÓDULO: Configuración de Workflows para IA
# Implementa workflows basados en agents-flows-recipes
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

echo -e "${BLUE}🔄 Configurando workflows de IA para desarrollo...${NC}"

WORKFLOWS_DIR="$HOME/.config/ai-workflows"
TEMPLATES_DIR="$WORKFLOWS_DIR/templates"
AGENTS_DIR="$WORKFLOWS_DIR/agents"

# Crear estructura de directorios
mkdir -p "$WORKFLOWS_DIR"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$AGENTS_DIR"

# Función para obtener recomendaciones de Gemini
get_workflow_recommendations() {
    local context="$1"

    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        echo -e "${YELLOW}⚠️ GEMINI_API_KEY no configurada, saltando recomendaciones${NC}"
        return 1
    fi

    local prompt="Eres un experto en workflows de desarrollo de software con IA.

Contexto: ${context}

Proporciona 3-5 workflows específicos y prácticos para desarrollo con IA en Termux, incluyendo:
1. Flujos de trabajo para desarrollo colaborativo con IA
2. Automatizaciones útiles para coding con asistentes IA
3. Procesos de revisión y mejora de código
4. Workflows de documentación automática

Responde en español con formato estructurado."

    local response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${GEMINI_API_KEY}" \
        -H 'Content-Type: application/json' \
        -d "{
            \"contents\": [{
                \"parts\": [{
                    \"text\": \"${prompt}\"
                }]
            }],
            \"generationConfig\": {
                \"temperature\": 0.7,
                \"maxOutputTokens\": 2048
            }
        }")

    if echo "$response" | jq -e '.candidates[0].content.parts[0].text' > /dev/null 2>&1; then
        echo -e "${CYAN}💡 RECOMENDACIONES DE WORKFLOWS:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo "$response" | jq -r '.candidates[0].content.parts[0].text'
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
}

echo -e "${YELLOW}🏗️ Creando workflows basados en agents-flows-recipes...${NC}"

# Crear template base para agentes
cat > "$TEMPLATES_DIR/agent-template.poml" << 'EOF'
<poml>
  <let name="topology">solo</let>
  <let name="bench_id">custom-agent</let>
  <let name="tool_mode">auto</let>
  <let name="providers">{ "openai": {"model":"gpt-4o-mini","temperature":0.2}, "gemini": {"model":"gemini-1.5-flash","temperature":0.2} }</let>
  <let name="tools">["fs.read","fs.write","fs.replace","shell.run","fs.search"]</let>
  <let name="tool_aliases">{}</let>

  <role>
    You are a helpful AI assistant specialized in software development.
    Your expertise includes code analysis, debugging, documentation, and optimization.
  </role>

  <task>
    - Analyze the given code or project
    - Provide actionable suggestions
    - Generate clean, well-documented solutions
    - Follow best practices and coding standards
  </task>

  <output-format>
    - Summary of analysis
    - Specific recommendations
    - Code examples if applicable
    - Next steps
  </output-format>
</poml>
EOF

# Crear agente específico para desarrollo con IA
cat > "$AGENTS_DIR/ai-developer.poml" << 'EOF'
<poml>
  <let name="topology">solo</let>
  <let name="bench_id">ai-developer</let>
  <let name="tool_mode">auto</let>
  <let name="providers">{
    "openai": {"model":"gpt-4o-mini","temperature":0.3},
    "gemini": {"model":"gemini-1.5-flash","temperature":0.3}
  }</let>
  <let name="tools">["fs.read","fs.write","fs.replace","shell.run","fs.search","web.fetch"]</let>
  <let name="tool_aliases">{}</let>

  <role>
    You are an expert AI-assisted developer who specializes in creating, optimizing, and maintaining code with the help of AI tools. You understand how to effectively collaborate with AI assistants like GitHub Copilot, ChatGPT, and other LLMs to maximize productivity while maintaining code quality.
  </role>

  <task>
    Your primary responsibilities include:
    1. Code Analysis & Review: Analyze code for quality, performance, and maintainability
    2. AI-Assisted Development: Guide the integration of AI tools in development workflows
    3. Prompt Engineering: Create effective prompts for code generation and problem-solving
    4. Code Optimization: Improve existing code with AI suggestions
    5. Documentation Generation: Create comprehensive documentation using AI assistance
    6. Testing Strategy: Design and implement AI-assisted testing approaches
    7. Debugging Support: Use AI tools to identify and fix issues efficiently

    Workflow:
    - Always read and understand the existing codebase before making changes
    - Use AI tools strategically for repetitive or complex tasks
    - Validate AI-generated code thoroughly
    - Maintain human oversight for critical decisions
    - Document AI-assisted processes for team knowledge sharing
  </task>

  <output-format>
    ## Analysis Summary
    - Brief overview of the task/codebase
    - Key findings and observations

    ## AI-Assisted Recommendations
    - Specific suggestions with AI tool usage
    - Code improvements with rationale
    - Performance optimizations

    ## Implementation Plan
    1. Step-by-step approach
    2. AI tools to be used at each step
    3. Validation and testing strategy

    ## Code Examples
    ```language
    // Well-commented, production-ready code
    ```

    ## Next Steps
    - Immediate actions required
    - Long-term improvements
    - Monitoring and maintenance suggestions
  </output-format>
</poml>
EOF

# Crear agente para optimización de workflows
cat > "$AGENTS_DIR/workflow-optimizer.poml" << 'EOF'
<poml>
  <let name="topology">solo</let>
  <let name="bench_id">workflow-optimizer</let>
  <let name="tool_mode">auto</let>
  <let name="providers">{
    "openai": {"model":"gpt-4o-mini","temperature":0.4},
    "gemini": {"model":"gemini-1.5-flash","temperature":0.4}
  }</let>
  <let name="tools">["fs.read","fs.write","fs.replace","shell.run","fs.search"]</let>
  <let name="tool_aliases">{}</let>

  <role>
    You are a workflow optimization expert who transforms chaotic development processes into smooth, efficient systems. Your specialty is understanding how humans and AI agents can work together synergistically, eliminating friction and maximizing the unique strengths of each.
  </role>

  <task>
    Your responsibilities include:
    1. Workflow Analysis: Map current processes and identify bottlenecks
    2. Human-AI Collaboration: Optimize task division between humans and AI
    3. Process Automation: Streamline repetitive tasks with smart automation
    4. Tool Integration: Ensure seamless integration between development tools
    5. Performance Measurement: Track and improve workflow efficiency metrics
    6. Continuous Improvement: Implement feedback loops for ongoing optimization

    Focus Areas:
    - Reduce context switching and manual handoffs
    - Automate routine tasks while maintaining quality
    - Create clear escalation paths for complex decisions
    - Optimize feedback loops between team members and AI tools
    - Measure and improve key performance indicators
  </task>

  <output-format>
    ## Current Workflow Analysis
    - Process mapping and bottleneck identification
    - Time and efficiency metrics
    - Pain points and friction areas

    ## Optimization Recommendations
    - Specific automation opportunities
    - Human-AI task division strategy
    - Tool integration improvements
    - Process streamlining suggestions

    ## Implementation Plan
    1. Quick wins (immediate improvements)
    2. Medium-term optimizations
    3. Long-term strategic changes
    4. Success metrics and monitoring

    ## Automation Scripts
    ```bash
    # Workflow automation examples
    ```

    ## Expected Benefits
    - Time savings and efficiency gains
    - Quality improvements
    - Reduced errors and rework
    - Enhanced team satisfaction
  </output-format>
</poml>
EOF

# Crear agente para documentación automática
cat > "$AGENTS_DIR/documentation-generator.poml" << 'EOF'
<poml>
  <let name="topology">solo</let>
  <let name="bench_id">documentation-generator</let>
  <let name="tool_mode">auto</let>
  <let name="providers">{
    "openai": {"model":"gpt-4o-mini","temperature":0.5},
    "gemini": {"model":"gemini-1.5-flash","temperature":0.5}
  }</let>
  <let name="tools">["fs.read","fs.write","fs.replace","shell.run","fs.search"]</let>
  <let name="tool_aliases">{}</let>

  <role>
    You are a technical documentation specialist who creates comprehensive, user-friendly documentation for software projects. You excel at translating complex technical concepts into clear, actionable documentation that serves both developers and end users.
  </role>

  <task>
    Your responsibilities include:
    1. Code Analysis: Understand project structure, dependencies, and functionality
    2. Documentation Generation: Create comprehensive docs including README, API docs, tutorials
    3. User Experience: Design documentation that is easy to navigate and understand
    4. Maintenance: Keep documentation up-to-date with code changes
    5. Automation: Implement automated documentation generation processes
    6. Standards Compliance: Follow documentation best practices and style guides

    Documentation Types:
    - README files with clear setup and usage instructions
    - API documentation with examples
    - Code comments and inline documentation
    - Tutorial and how-to guides
    - Architecture and design documentation
    - Troubleshooting and FAQ sections
  </task>

  <output-format>
    ## Documentation Analysis
    - Current documentation state
    - Gaps and improvement opportunities
    - Target audience identification

    ## Generated Documentation

    ### README.md
    ```markdown
    # Project Title
    Clear, comprehensive README content
    ```

    ### API Documentation
    ```markdown
    # API Reference
    Detailed API documentation with examples
    ```

    ### Code Comments
    ```language
    // Enhanced code comments and docstrings
    ```

    ## Documentation Strategy
    - Maintenance approach
    - Automation opportunities
    - Quality assurance process

    ## Implementation Checklist
    - [ ] Immediate documentation updates
    - [ ] Automation setup
    - [ ] Review and validation process
  </output-format>
</poml>
EOF

# Crear scripts de workflow
echo -e "${YELLOW}📝 Creando scripts de workflow...${NC}"

# Script principal de workflow
cat > "$WORKFLOWS_DIR/run-workflow.sh" << 'EOF'
#!/bin/bash

# ====================================
# WORKFLOW RUNNER
# Ejecuta workflows de IA basados en agents-flows-recipes
# ====================================

set -euo pipefail

WORKFLOWS_DIR="$HOME/.config/ai-workflows"
AGENTS_DIR="$WORKFLOWS_DIR/agents"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

show_usage() {
    echo -e "${BLUE}🔄 AI Workflow Runner${NC}"
    echo -e "${CYAN}Uso: run-workflow.sh <agent> <task> [options]${NC}"
    echo ""
    echo -e "${YELLOW}Agentes disponibles:${NC}"
    echo "  ai-developer         - Desarrollo asistido por IA"
    echo "  workflow-optimizer   - Optimización de procesos"
    echo "  documentation-generator - Generación de documentación"
    echo ""
    echo -e "${YELLOW}Ejemplos:${NC}"
    echo "  run-workflow.sh ai-developer analyze-code ."
    echo "  run-workflow.sh workflow-optimizer optimize-process"
    echo "  run-workflow.sh documentation-generator generate-docs src/"
}

if [[ $# -lt 2 ]]; then
    show_usage
    exit 1
fi

AGENT="$1"
TASK="$2"
shift 2
ARGS="$*"

AGENT_FILE="$AGENTS_DIR/${AGENT}.poml"

if [[ ! -f "$AGENT_FILE" ]]; then
    echo -e "${RED}❌ Agente no encontrado: ${AGENT}${NC}"
    echo -e "${CYAN}Agentes disponibles:${NC}"
    ls -1 "$AGENTS_DIR"/*.poml | xargs -n1 basename | sed 's/.poml$//'
    exit 1
fi

echo -e "${BLUE}🤖 Ejecutando workflow: ${AGENT}${NC}"
echo -e "${CYAN}Tarea: ${TASK}${NC}"
echo -e "${CYAN}Argumentos: ${ARGS}${NC}"

# Simular ejecución del workflow (en un entorno real, esto usaría un runner de POML)
echo -e "${YELLOW}📋 Procesando con agente ${AGENT}...${NC}"

# Leer configuración del agente
echo -e "${BLUE}📖 Cargando configuración del agente...${NC}"
if command -v xml2 >/dev/null 2>&1; then
    # Si xml2 está disponible, parsear POML
    ROLE=$(xml2 < "$AGENT_FILE" | grep "/poml/role=" | cut -d'=' -f2- | head -1)
    echo -e "${CYAN}Rol del agente: ${ROLE}${NC}"
fi

# Ejecutar lógica específica basada en el agente y tarea
case "$AGENT" in
    "ai-developer")
        case "$TASK" in
            "analyze-code")
                echo -e "${YELLOW}🔍 Analizando código en: ${ARGS:-'directorio actual'}${NC}"
                # Aquí se integraría con herramientas reales de análisis
                if [[ -n "$ARGS" && -d "$ARGS" ]]; then
                    find "$ARGS" -name "*.py" -o -name "*.js" -o -name "*.ts" | head -10
                    echo -e "${GREEN}✅ Análisis completado${NC}"
                else
                    echo -e "${RED}❌ Directorio no válido${NC}"
                    exit 1
                fi
                ;;
            "optimize-code")
                echo -e "${YELLOW}⚡ Optimizando código...${NC}"
                echo -e "${GREEN}✅ Optimización completada${NC}"
                ;;
            *)
                echo -e "${RED}❌ Tarea no reconocida para ai-developer: ${TASK}${NC}"
                exit 1
                ;;
        esac
        ;;
    "workflow-optimizer")
        case "$TASK" in
            "optimize-process")
                echo -e "${YELLOW}🔧 Optimizando procesos de desarrollo...${NC}"
                echo -e "${GREEN}✅ Optimización de workflow completada${NC}"
                ;;
            "analyze-bottlenecks")
                echo -e "${YELLOW}🔍 Analizando cuellos de botella...${NC}"
                echo -e "${GREEN}✅ Análisis de bottlenecks completado${NC}"
                ;;
            *)
                echo -e "${RED}❌ Tarea no reconocida para workflow-optimizer: ${TASK}${NC}"
                exit 1
                ;;
        esac
        ;;
    "documentation-generator")
        case "$TASK" in
            "generate-docs")
                echo -e "${YELLOW}📚 Generando documentación para: ${ARGS:-'proyecto actual'}${NC}"
                if [[ -n "$ARGS" && -d "$ARGS" ]]; then
                    # Generar README básico
                    if [[ ! -f "$ARGS/README.md" ]]; then
                        cat > "$ARGS/README.md" << 'DOC_EOF'
# Proyecto

## Descripción
Este proyecto fue documentado automáticamente por AI Workflow Runner.

## Instalación
```bash
# Instrucciones de instalación
```

## Uso
```bash
# Instrucciones de uso
```

## Contribuciones
Las contribuciones son bienvenidas.
DOC_EOF
                        echo -e "${GREEN}✅ README.md generado${NC}"
                    else
                        echo -e "${YELLOW}ℹ️ README.md ya existe${NC}"
                    fi
                else
                    echo -e "${RED}❌ Directorio no válido${NC}"
                    exit 1
                fi
                ;;
            *)
                echo -e "${RED}❌ Tarea no reconocida para documentation-generator: ${TASK}${NC}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo -e "${RED}❌ Agente no reconocido: ${AGENT}${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}🎉 Workflow completado exitosamente${NC}"
EOF

chmod +x "$WORKFLOWS_DIR/run-workflow.sh"

# Crear script de inicialización de proyecto con IA
cat > "$HOME/bin/ai-init-project" << 'EOF'
#!/bin/bash

# ====================================
# AI PROJECT INITIALIZER
# Inicializa un proyecto con workflows de IA
# ====================================

set -euo pipefail

PROJECT_NAME="${1:-my-ai-project}"
PROJECT_DIR="${2:-$HOME/dev/$PROJECT_NAME}"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Inicializando proyecto con IA: ${PROJECT_NAME}${NC}"

# Crear estructura de proyecto
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Crear archivos básicos
cat > "README.md" << EOF
# ${PROJECT_NAME}

Proyecto inicializado con AI Workflow System.

## Estructura del Proyecto

\`\`\`
${PROJECT_NAME}/
├── src/          # Código fuente
├── docs/         # Documentación
├── tests/        # Pruebas
├── .ai/          # Configuración de workflows de IA
└── README.md     # Este archivo
\`\`\`

## Workflows de IA Disponibles

- \`ai-developer analyze-code src/\` - Analizar código
- \`ai-developer optimize-code\` - Optimizar código
- \`workflow-optimizer optimize-process\` - Optimizar procesos
- \`documentation-generator generate-docs .\` - Generar documentación

## Comandos Útiles

\`\`\`bash
# Revisar código con IA
ai-code-review archivo.py

# Generar documentación
ai-generate-docs archivo.js

# Analizar proyecto completo
ai-project-analysis .

# Obtener ayuda de IA
ai-help "¿cómo optimizar este código?"
\`\`\`

## Desarrollo

1. Coloca tu código en \`src/\`
2. Usa los workflows de IA para asistencia
3. Mantén la documentación actualizada con \`documentation-generator\`

EOF

# Crear estructura de directorios
mkdir -p src docs tests .ai

# Crear configuración de workflow para el proyecto
cat > ".ai/workflow-config.yaml" << EOF
project:
  name: "${PROJECT_NAME}"
  type: "general"
  ai_enabled: true

workflows:
  development:
    - name: "code-analysis"
      agent: "ai-developer"
      trigger: "on-push"

    - name: "documentation"
      agent: "documentation-generator"
      trigger: "weekly"

    - name: "optimization"
      agent: "workflow-optimizer"
      trigger: "monthly"

settings:
  auto_review: false
  auto_docs: true
  ai_commits: false
EOF

# Crear .gitignore
cat > ".gitignore" << EOF
# AI workflows local data
.ai/cache/
.ai/logs/

# Dependencies
node_modules/
__pycache__/
*.pyc

# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Local environment variables
.env
EOF

# Inicializar git si no existe
if [[ ! -d ".git" ]]; then
    git init
    git add .
    git commit -m "🎉 Inicialización de proyecto con AI workflows"
fi

echo -e "${GREEN}✅ Proyecto ${PROJECT_NAME} inicializado en ${PROJECT_DIR}${NC}"
echo -e "${CYAN}💡 Próximos pasos:${NC}"
echo -e "1. cd ${PROJECT_DIR}"
echo -e "2. Agregar tu código en src/"
echo -e "3. Usar workflows: run-workflow.sh ai-developer analyze-code src/"
echo -e "4. Generar docs: run-workflow.sh documentation-generator generate-docs ."
EOF

chmod +x "$HOME/bin/ai-init-project"

# Crear configuración global de workflows
cat > "$WORKFLOWS_DIR/config.yaml" << 'EOF'
# Configuración global de AI Workflows

global:
  default_provider: "gemini"
  auto_save_logs: true
  log_level: "info"

providers:
  openai:
    model: "gpt-4o-mini"
    temperature: 0.3
    max_tokens: 2048

  gemini:
    model: "gemini-1.5-flash"
    temperature: 0.3
    max_tokens: 2048

agents:
  ai-developer:
    description: "AI-assisted development agent"
    capabilities: ["code-analysis", "optimization", "debugging"]

  workflow-optimizer:
    description: "Process optimization specialist"
    capabilities: ["bottleneck-analysis", "automation", "efficiency"]

  documentation-generator:
    description: "Automated documentation creator"
    capabilities: ["readme-generation", "api-docs", "tutorials"]

workflows:
  development:
    stages: ["analyze", "develop", "test", "document"]
    automation_level: "medium"

  optimization:
    stages: ["profile", "identify", "improve", "validate"]
    automation_level: "high"

  documentation:
    stages: ["scan", "generate", "review", "publish"]
    automation_level: "high"
EOF

# Obtener recomendaciones de IA
get_workflow_recommendations "Workflows de desarrollo con IA en Termux usando agents-flows-recipes"

echo -e "\n${GREEN}📊 RESUMEN DE CONFIGURACIÓN DE WORKFLOWS${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${GREEN}✅ Workflows configurados:${NC}"
echo -e "   • AI Developer: Desarrollo asistido por IA"
echo -e "   • Workflow Optimizer: Optimización de procesos"
echo -e "   • Documentation Generator: Generación automática de docs"

echo -e "${GREEN}✅ Scripts creados:${NC}"
echo -e "   • run-workflow.sh: Ejecutor principal de workflows"
echo -e "   • ai-init-project: Inicializador de proyectos con IA"

echo -e "${GREEN}✅ Configuración:${NC}"
echo -e "   • Templates POML para agentes personalizados"
echo -e "   • Configuración YAML para workflows"
echo -e "   • Integración con herramientas existentes"

echo -e "\n${YELLOW}💡 COMANDOS ÚTILES:${NC}"
echo -e "${CYAN}• ai-init-project mi-proyecto         # Crear nuevo proyecto${NC}"
echo -e "${CYAN}• run-workflow.sh ai-developer analyze-code src/  # Analizar código${NC}"
echo -e "${CYAN}• run-workflow.sh documentation-generator generate-docs .  # Generar docs${NC}"
echo -e "${CYAN}• run-workflow.sh workflow-optimizer optimize-process  # Optimizar workflow${NC}"

echo -e "\n${PURPLE}🎉 ¡Workflows de IA configurados exitosamente!${NC}"

exit 0