# 🪟 Guía de Instalación para Windows - Rastafari Neovim

## 🎯 Requisitos del Sistema

### Requisitos Mínimos
- **Sistema Operativo**: Windows 10/11 (64-bit)
- **RAM**: 4GB mínimo, 8GB recomendado
- **Espacio en Disco**: 2GB para instalación completa
- **PowerShell**: 5.1 o superior (incluido en Windows)
- **Privilegios**: No se requieren permisos de administrador

### Compatibilidad
- ✅ **Windows 11** - Completamente soportado
- ✅ **Windows 10** (1903+) - Completamente soportado
- ✅ **WSL/WSL2** - Instalación nativa de Linux
- ⚠️ **Windows 8.1** - Soporte limitado
- ❌ **Windows 7** - No soportado

---

## 🚀 Métodos de Instalación

### Método 1: Instalación Automática (Recomendado)

#### Paso 1: Preparar PowerShell
```powershell
# Ejecutar como usuario normal (NO como administrador)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Paso 2: Descargar e Instalar
```powershell
# Clonar repositorio
git clone https://github.com/tu-usuario/termux-dev-nvim-agents.git
cd termux-dev-nvim-agents

# Ejecutar instalador
.\scripts\install-cross-platform-nvim.sh
```

### Método 2: Instalación Manual

#### Paso 1: Instalar Neovim
**Opción A - Winget (Recomendado)**:
```powershell
winget install Neovim.Neovim
```

**Opción B - Chocolatey**:
```powershell
# Instalar Chocolatey primero si no lo tienes
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar Neovim
choco install neovim
```

**Opción C - Descarga Manual**:
1. Descargar desde: https://neovim.io/
2. Extraer a `C:\Program Files\Neovim`
3. Agregar a PATH: `C:\Program Files\Neovim\bin`

#### Paso 2: Instalar Dependencias
```powershell
# Node.js (para LSP)
winget install OpenJS.NodeJS

# Python (para plugins)
winget install Python.Python.3

# Git (si no está instalado)
winget install Git.Git

# Ripgrep (búsqueda rápida)
winget install BurntSushi.ripgrep.MSVC
```

#### Paso 3: Configurar Directorio
```powershell
# Crear directorio de configuración
$configDir = "$env:LOCALAPPDATA\nvim"
New-Item -ItemType Directory -Path $configDir -Force

# Copiar configuración Rastafari
Copy-Item -Recurse "config\neovim\*" "$configDir\"
```

---

## ⚙️ Configuración Avanzada

### Variables de Entorno Windows
```powershell
# Configurar variables permanentes
[Environment]::SetEnvironmentVariable("RASTAFARI_PLATFORM", "windows", "User")
[Environment]::SetEnvironmentVariable("NVIM_APPNAME", "rastafari-nvim", "User")

# Variables opcionales para rendimiento
[Environment]::SetEnvironmentVariable("NVIM_PERF_MODE", "true", "User")
[Environment]::SetEnvironmentVariable("NVIM_LOG_LEVEL", "warn", "User")
```

### Configuración de Terminal
**Windows Terminal (Recomendado)**:
```json
{
    "name": "Rastafari Neovim",
    "commandline": "nvim",
    "icon": "🌿",
    "colorScheme": "Rastafari",
    "font": {
        "face": "JetBrains Mono NL",
        "size": 11
    }
}
```

### Esquema de Colores Windows Terminal
```json
{
    "name": "Rastafari",
    "background": "#1e1e1e",
    "foreground": "#f5f5f5",
    "black": "#2d2d2d",
    "red": "#ff6b6b",
    "green": "#6bcf7f",
    "yellow": "#ffd93d",
    "blue": "#74b9ff",
    "purple": "#fd79a8",
    "cyan": "#00cec9",
    "white": "#f5f5f5",
    "brightBlack": "#636e72",
    "brightRed": "#ff7675",
    "brightGreen": "#00b894",
    "brightYellow": "#fdcb6e",
    "brightBlue": "#0984e3",
    "brightPurple": "#e84393",
    "brightCyan": "#00b894",
    "brightWhite": "#ffffff"
}
```

---

## 🔧 Configuraciones Específicas de Windows

### Rendimiento Optimizado
```lua
-- En tu init.lua personal
if vim.fn.has('win32') == 1 then
    -- Configuraciones específicas para Windows
    vim.g.python3_host_prog = 'python'  -- Usar Python del PATH
    vim.opt.shell = 'powershell'        -- Usar PowerShell
    vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'

    -- Optimizaciones de rendimiento
    vim.opt.updatetime = 100    -- Actualización más rápida
    vim.opt.timeoutlen = 500    -- Timeout de teclas más corto
end
```

### LSP para Desarrollo Windows
```lua
-- Mason configuración Windows
require('mason').setup({
    providers = {
        "mason.providers.registry-api",
        "mason.providers.client"
    },
    github = {
        download_url_template = "https://github.com/%s/releases/download/%s/%s"
    }
})

-- Servidores LSP recomendados para Windows
require('mason-lspconfig').setup({
    ensure_installed = {
        'powershell_es',  -- PowerShell
        'omnisharp',      -- C#/.NET
        'tsserver',       -- TypeScript/JavaScript
        'pyright',        -- Python
        'lua_ls',         -- Lua
        'jsonls',         -- JSON
        'yamlls'          -- YAML
    }
})
```

---

## 🛠️ Troubleshooting Windows

### Problema: PowerShell Execution Policy
**Error**: `cannot be loaded because running scripts is disabled`
```powershell
# Solución:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problema: Neovim No Encuentra Python
**Error**: `Python3 provider not found`
```powershell
# Verificar Python
python --version
where python

# Si no está en PATH:
$env:PATH += ";C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python311"
```

### Problema: Fonts No Se Ven Correctamente
**Solución**:
1. Instalar Nerd Font: https://www.nerdfonts.com/font-downloads
2. Configurar en Windows Terminal:
```json
{
    "font": {
        "face": "JetBrainsMono Nerd Font",
        "size": 11
    }
}
```

### Problema: Mason No Puede Descargar LSP
**Causa**: Firewall o proxy corporativo
```powershell
# Verificar conectividad
Test-NetConnection -ComputerName github.com -Port 443

# Configurar proxy si es necesario
$env:HTTP_PROXY = "http://proxy.empresa.com:8080"
$env:HTTPS_PROXY = "http://proxy.empresa.com:8080"
```

### Problema: Rendimiento Lento
**Soluciones**:
1. **Excluir del Antivirus**:
   - `%LOCALAPPDATA%\nvim`
   - `%LOCALAPPDATA%\nvim-data`

2. **Configuración de Rendimiento**:
```lua
-- En tu configuración
vim.opt.updatetime = 100
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('cache') .. '/undo'
```

---

## 🔍 Comandos de Diagnóstico

### Verificar Instalación
```powershell
# Verificar Neovim
nvim --version

# Verificar configuración
nvim --headless -c "checkhealth" -c "qall"

# Verificar plugins
nvim --headless -c "Lazy health" -c "qall"
```

### Script de Diagnóstico Automático
```powershell
# Crear script de diagnóstico
$diagScript = @"
Write-Host "🔍 Rastafari Neovim Diagnostic" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Verificar Neovim
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Write-Host "✅ Neovim: " -NoNewline -ForegroundColor Green
    nvim --version | Select-Object -First 1
} else {
    Write-Host "❌ Neovim no encontrado" -ForegroundColor Red
}

# Verificar Python
if (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host "✅ Python: " -NoNewline -ForegroundColor Green
    python --version
} else {
    Write-Host "❌ Python no encontrado" -ForegroundColor Red
}

# Verificar Node.js
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "✅ Node.js: " -NoNewline -ForegroundColor Green
    node --version
} else {
    Write-Host "❌ Node.js no encontrado" -ForegroundColor Red
}

# Verificar configuración
`$configPath = "`$env:LOCALAPPDATA\nvim"
if (Test-Path `$configPath) {
    Write-Host "✅ Configuración encontrada: `$configPath" -ForegroundColor Green
} else {
    Write-Host "❌ Configuración no encontrada" -ForegroundColor Red
}
"@

$diagScript | Out-File -FilePath "rastafari-diagnostic.ps1" -Encoding UTF8
```

---

## 🚀 Comandos Útiles Windows

### Alias PowerShell para Rastafari
```powershell
# Agregar al perfil de PowerShell
notepad $PROFILE

# Agregar estas líneas:
function rasta-nvim { nvim $args }
function rasta-config { nvim "$env:LOCALAPPDATA\nvim" }
function rasta-tips { bash "$PWD\scripts\rastafari-tips.sh" }
function rasta-tutorial { bash "$PWD\scripts\rastafari-tutorial.sh" }

# Alias adicionales
Set-Alias rv rasta-nvim
Set-Alias rc rasta-config
```

### Script de Actualización
```powershell
# Crear actualizador automático
$updateScript = @"
Write-Host "🔄 Actualizando Rastafari Neovim..." -ForegroundColor Yellow
git pull origin main
Copy-Item -Recurse "config\neovim\*" "`$env:LOCALAPPDATA\nvim\" -Force
Write-Host "✅ Actualización completada!" -ForegroundColor Green
"@

$updateScript | Out-File -FilePath "update-rastafari.ps1" -Encoding UTF8
```

---

## 📚 Recursos Adicionales

### Documentación Oficial
- [Neovim Windows Guide](https://neovim.io/doc/user/os_win32.html)
- [LazyVim Documentation](https://lazyvim.github.io/)
- [Mason Registry](https://mason-registry.dev/)

### Herramientas Recomendadas
- **Terminal**: Windows Terminal
- **Shell**: PowerShell 7+
- **Font**: JetBrains Mono Nerd Font
- **Git Client**: Git for Windows + Windows Terminal

### Comunidad
- [Discord Rastafari Neovim](https://discord.gg/rastafari-nvim)
- [GitHub Issues](https://github.com/tu-usuario/termux-dev-nvim-agents/issues)
- [Subreddit Neovim](https://reddit.com/r/neovim)

---

## ✅ Checklist de Instalación Completa

- [ ] ✅ Windows 10/11 verificado
- [ ] ✅ PowerShell execution policy configurado
- [ ] ✅ Neovim instalado y en PATH
- [ ] ✅ Node.js y Python instalados
- [ ] ✅ Git configurado
- [ ] ✅ Configuración Rastafari copiada
- [ ] ✅ Windows Terminal configurado
- [ ] ✅ Nerd Font instalada
- [ ] ✅ `:checkhealth` sin errores críticos
- [ ] ✅ Mason LSP funcionando
- [ ] ✅ Plugins cargando correctamente
- [ ] ✅ Colorscheme Rastafari activo
- [ ] ✅ Dashboard personalizado visible

**¡Bienvenido a la familia Rastafari! 💚💛❤️**

*"One love, one terminal, one Neovim!"*