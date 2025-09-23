# Configuración Zsh Rastafari - Termux AI Setup

## 🌈 Descripción

Esta configuración completa de Zsh incluye:

- **Oh My Zsh** con plugins esenciales
- **Powerlevel10k** con tema Rastafari personalizado (colores rojo, amarillo, verde)
- **Yazi** file manager con integración optimizada
- **Métricas de sistema** en tiempo real (CPU y Memoria)
- **Aliases y funciones** útiles para desarrollo
- **Integración con herramientas modernas** (fd, rg, fzf, bat, exa)

## 🚀 Instalación

### 1. Ejecutar el script principal:
```bash
./modules/01-zsh-setup.sh
```

### 2. Aplicar configuración completa:
```bash
./config/configure-zsh-final.sh
```

### 3. Validar instalación:
```bash
./config/validate-zsh-setup.sh
```

## 🎨 Características del Tema Rastafari

- **Colores**: Rojo, Amarillo y Verde en bloques
- **CPU y Memoria**: Mostrados en tiempo real con códigos de colores
- **Comando en línea separada**: Para mejor visibilidad
- **Estilo Rainbow continuo**: Sin separadores entre segmentos
- **Integración perfecta con Yazi**: File explorer optimizado

## 🗂️ Integración con Yazi

### Comandos disponibles:
- `yy` - Yazi con cambio de directorio automático
- `yp` - Yazi en modo preview
- `yz` - Yazi con integración fzf
- `ys` - Yazi mostrando directorio de destino
- `ya` - Acceso rápido a Yazi
- `yf` - Seleccionar directorio con fzf antes de abrir Yazi

## 📁 Estructura de Archivos

```
config/zsh/
├── aliases.zsh              # Aliases personalizados
├── functions.zsh            # Funciones útiles
├── p10k-config.zsh         # Configuración Powerlevel10k
├── yazi-integration.zsh    # Integración optimizada con Yazi
└── main-zshrc.template     # Template del .zshrc principal

config/
├── configure-zsh-final.sh  # Script de configuración final
└── validate-zsh-setup.sh   # Script de validación
```

## 🛠️ Herramientas Opcionales

Para funcionalidad completa, instala:
- `fd` - Buscador de archivos mejorado
- `rg` (ripgrep) - Búsqueda en contenido de archivos
- `fzf` - Fuzzy finder
- `bat` - Cat mejorado con syntax highlighting
- `exa` - Ls mejorado con iconos
- `zoxide` - CD inteligente con historial

## 🎯 Funciones Útiles

- `sysinfo` - Información del sistema
- `sysupdate` - Actualizar todo el sistema
- `setup-ai-keys` - Configurar APIs de IA
- `mkcd <dir>` - Crear directorio y navegar
- `extract <file>` - Extraer archivos automáticamente
- `ff <pattern>` - Buscar archivos
- `fff <pattern>` - Buscar en contenido

## 🔧 Personalización

### Cambiar colores del tema:
Edita `~/.p10k.zsh` y modifica las variables `POWERLEVEL9K_*_BACKGROUND` y `POWERLEVEL9K_*_FOREGROUND`.

### Añadir aliases personalizados:
Edita `~/.config/zsh/aliases.zsh`

### Añadir funciones personalizadas:
Edita `~/.config/zsh/functions.zsh`

### Configuración local:
Crea `~/.zshrc.local` para configuraciones específicas del usuario.

## �� Solución de Problemas

1. **Tema no se ve correctamente**: 
   - Instala una fuente Nerd Font
   - Ejecuta `p10k configure`

2. **Yazi no funciona**:
   - Verifica que Rust esté instalado: `cargo --version`
   - Reinstala: `cargo install --locked yazi-fm yazi-cli`

3. **Plugins no cargan**:
   - Verifica Oh My Zsh: `echo $ZSH`
   - Reinicia el terminal completamente

4. **Validar configuración**:
   ```bash
   ./config/validate-zsh-setup.sh
   ```

## 📱 Específico para Termux

- Auto-start de Zsh configurado en `.bashrc`
- Configuración optimizada en `.termux/termux.properties`
- Aliases específicos para Termux (`apt`, `install`, etc.)

## 🌟 Comandos Rápidos

```bash
# Información del sistema
sysinfo

# Actualizar todo
sysupdate

# Abrir Yazi
yy

# Configurar APIs IA
setup-ai-keys

# Validar configuración
./config/validate-zsh-setup.sh
```
