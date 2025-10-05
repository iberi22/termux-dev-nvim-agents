# 🚀 Termux AI Setup - Entorno de Desarrollo con IA (v2025-09-25.1b42aca)

[![CI](https://github.com/iberi22/termux-dev-nvim-agents/actions/workflows/ci.yml/badge.svg)](https://github.com/iberi22/termux-dev-nvim-agents/actions/workflows/ci.yml)

Sistema automatizado de configuración de Termux con agente de IA integrado usando Gemini CLI. Instalación con un comando y asistente inteligente para administrar tu entorno de desarrollo.

## ✨ Características Principales

- **🤖 Agente IA Integrado**: Usa `: "tu pregunta"` para interactuar con Gemini 2.5-flash
- **⚡ Instalación Automática**: Un solo comando instala todo el entorno
- **🔐 Autenticación OAuth2**: Sin API keys manuales, autenticación persistente
- **🛠️ Entorno Completo**: Git, Node.js, Zsh, SSH configurados automáticamente
- **📱 Optimizado para Termux**: Especialmente diseñado para desarrollo en Android
- **✅ Validación de Dependencias**: Script de validación para asegurar que todas las dependencias de los agentes de IA estén instaladas.

## 🚀 Instalación Rápida

```bash
curl -L https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

### ¿Qué instala automáticamente?

- ✅ **Git** con configuración SSH para GitHub
- ✅ **Node.js LTS** para herramientas de desarrollo
- ✅ **Zsh + Oh My Zsh** con configuración personalizada
- ✅ **Gemini CLI** con autenticación OAuth2
- ✅ **Agente IA** accesible con `: "pregunta"`
- ✅ **Configuración SSH** para acceso remoto (opcional)
- ⚠️ **Neovim** disponible opcionalmente

## 🤖 Usando el Agente IA

Una vez instalado, usa el comando `:` (dos puntos) para interactuar:

```bash
# Ejemplos de uso
: "¿Cómo instalar Python en Termux?"
: "Configurar GitHub SSH"
: "Crear script de backup automático"
: "¿Por qué falla mi aplicación Node.js?"
: "Mejores prácticas para desarrollo móvil"
termux-ai-agent --help      # Ayuda completa
termux-ai-agent --status    # Estado del sistema
termux-ai-agent --setup     # Reconfigurar Gemini CLI
```

## 📋 Requisitos

- **Android** con Termux instalado
- **Conexión a internet** para descargas
- **Cuenta Google** para autenticación Gemini CLI

### Instalación en Windows (Desarrollo/Testing)

Para desarrollo en Windows usando Android Emulator:

```powershell
# 1. Instalar Android Studio y crear AVD con Android 13+
# 2. Descargar Termux desde F-Droid en el emulador
# 3. Ejecutar en Termux dentro del emulador:
curl -L https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

**Alternativamente**, usa WSL2 para una experiencia nativa:

```bash
# En WSL2 Ubuntu/Debian
curl -L https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

## 🔧 Configuración Manual

Si prefieres instalación paso a paso:

```bash
# Descargar repositorio
git clone https://github.com/iberi22/termux-dev-nvim-agents.git
cd termux-dev-nvim-agents

# Instalación interactiva
./quick-setup.sh

# O instalación automática
./quick-setup.sh --auto
```

## 🆘 Solución de Problemas

### Problema: Comando `:` no funciona

```bash
# Verificar instalación
which colon
termux-ai-agent --status

# Reinstalar agente
curl -L https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-agent.sh -o ~/bin/termux-ai-agent
chmod +x ~/bin/termux-ai-agent
```

### Problema: Error de autenticación Gemini

```bash
# Reconfigurar autenticación
gemini auth login

# Verificar estado
gemini auth test
```

### Problema: Node.js no encontrado

```bash
# Verificar instalación
node --version
npm --version
```

## �️ Herramientas Instaladas

| Herramienta | Propósito | Comando de Verificación |
|-------------|-----------|------------------------|
| Git | Control de versiones | `git --version` |
| Node.js | Runtime JavaScript | `node --version` |
| Zsh | Shell avanzado | `zsh --version` |
| Oh My Zsh | Framework Zsh | `ls ~/.oh-my-zsh` |
| Gemini CLI | IA Google | `gemini --version` |
| SSH | Acceso remoto | `ssh -V` |

## 🎯 Casos de Uso Comunes

### Desarrollo Web

```bash
: "Crear proyecto React en Termux"
: "Configurar servidor de desarrollo"
```

### Automatización

```bash
: "Script para backup de código"
: "Optimizar Termux para desarrollo"
: "Instalar herramientas de línea de comandos"
```

## 🔐 Configuración SSH (Opcional)

Para acceso remoto a tu dispositivo, el script instala y configura un servidor SSH.

### Gestión del Servidor SSH

Hemos incluido scripts de ayuda para facilitar la gestión del servidor:

-   `ssh-local-start`: Inicia el servidor SSH.
-   `ssh-local-stop`: Detiene el servidor SSH.
-   `ssh-local-info`: Muestra la información de conexión actual (IP, puerto, etc.).

**Ejemplo de uso:**

```bash
# Iniciar el servidor y ver cómo conectarse
ssh-local-start
```

Para conectar desde otra máquina en la misma red:

```bash
# El puerto por defecto es 8022
ssh -p 8022 tu_usuario@IP_DEL_DISPOSITIVO
```

## Quick Installation

One-liner (see "Instalación Rápida" above):

```bash
curl -L https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

## SSH/SFTP Access

Examples (see "Configuración SSH" above):

```bash
ssh -p 8022 usuario@IP_DEL_DISPOSITIVO
```

```bash
sftp -P 8022 usuario@IP_DEL_DISPOSITIVO
```

## Troubleshooting

See "🆘 Solución de Problemas" section above for common fixes.

## AI Commands

Use ':' to ask Gemini. Examples:

```bash
: "¿Cómo instalar Python en Termux?"
: "Configurar GitHub SSH"
```

## 📚 Documentación

- **[AGENTS.md](./AGENTS.md)** - Agentes IA soportados y configuración
- **[GEMINI.md](./GEMINI.md)** - Guía completa del CLI de Gemini
- **Especificaciones y Roadmap**: [SPEC](./specs/SPEC.md) · [ROADMAP](./specs/ROADMAP.md) · [TASKS](./specs/TASKS.md) · [PROGRESS](./specs/PROGRESS.md)

> **Regla del proyecto**: cada cambio relevante debe actualizar `specs/PROGRESS.md`.

## 🤝 Contribuir

```bash
# Fork del repositorio
git clone https://github.com/TU_USUARIO/termux-dev-nvim-agents.git

# Crear rama para cambios
git checkout -b nueva-caracteristica

# Realizar cambios y commit
git commit -m "Agregar nueva característica"

# Push y crear Pull Request
git push origin nueva-caracteristica
```

## � Licencia

MIT License - Ve [LICENSE](./LICENSE) para más detalles.

## 🙏 Agradecimientos

- **Google Gemini** por la API de IA
- **Termux Community** por el entorno Android
- **Oh My Zsh** por el framework de shell

## 📞 Soporte

- 🐛 **Issues**: [GitHub Issues](https://github.com/iberi22/termux-dev-nvim-agents/issues)
- � **Discusiones**: [GitHub Discussions](https://github.com/iberi22/termux-dev-nvim-agents/discussions)
- 📧 **Email**: Crear issue para contacto

---

### ⭐ Apóyanos

Si te ha sido útil, considera dar una estrella al repositorio.

```bash
# Comando rápido de instalación
curl -L https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```
