# 🇯🇲 TEMA RASTAFARI PARA POWERLEVEL10K 🇯🇲

## 🌈 Descripción General

Este tema personalizado para Powerlevel10k implementa un estilo "Rainbow" inspirado en los colores rastafari (rojo, amarillo, verde) con métricas de sistema en tiempo real y un layout optimizado para desarrollo.

## 🎨 Características Principales

### ✅ **Esquema de Colores Rastafari**
- **🔴 ROJO**: OS Icon, Status Error, Elementos críticos del sistema
- **🟡 AMARILLO**: Git Status, Background Jobs, Virtual Environment
- **🟢 VERDE**: Directory, Context, Status OK, Métricas de bajo uso

### ✅ **Layout Rainbow en Bloque**
```
[OS🔴][Git🟡][Dir🟢][CPU🟡][Mem🟢][Status🟢][Jobs🟡][Context🟢]
❯ comando-aquí
```

### ✅ **Métricas de Sistema en Tiempo Real**
- **🔥 CPU Usage**: Porcentaje de uso del procesador
- **💾 Memory Free**: Memoria libre disponible en MB
- **🎨 Colores Dinámicos**:
  - Verde < 30% uso
  - Amarillo 30-70% uso
  - Rojo > 70% uso

## 🔧 Archivos Modificados

### **`modules/01-zsh-setup.sh`**
- ✅ Configuración completa de Powerlevel10k rastafari
- ✅ Funciones personalizadas para CPU y memoria
- ✅ Esquema de colores rastafari implementado
- ✅ Layout en bloques con comando en nueva línea

### **`modules/rastafari-theme-demo.sh`** (NUEVO)
- ✅ Script interactivo de demostración
- ✅ Verificación de instalación
- ✅ Métricas del sistema en tiempo real
- ✅ Comandos útiles y troubleshooting

### **`setup.sh`**
- ✅ Nueva opción `R` para demo del tema rastafari
- ✅ Integración en el menú principal

## 🎯 Funcionalidades Implementadas

### **1. Configuración de Segmentos**
```bash
# Segmentos del prompt (línea superior)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon          # OS - ROJO
    dir              # Directorio - VERDE
    vcs              # Git - AMARILLO
    system_cpu       # CPU - Dinámico
    system_memory    # Memoria - Dinámico
    status           # Status - VERDE/ROJO
    background_jobs  # Jobs - AMARILLO
    virtualenv       # Python venv - AMARILLO
    context          # user@host - VERDE
)
```

### **2. Funciones Personalizadas de Sistema**

#### **CPU Monitor**
```bash
function prompt_system_cpu() {
    # Lee /proc/stat para obtener uso de CPU
    # Colores: Verde<30%, Amarillo<70%, Rojo>70%
    # Muestra: "CPU 25%"
}
```

#### **Memory Monitor**
```bash
function prompt_system_memory() {
    # Lee /proc/meminfo para memoria disponible
    # Colores: Verde<30%, Amarillo<70%, Rojo>70%
    # Muestra: "1024MB Free"
}
```

### **3. Configuración de Layout**
```bash
# Prompt multilínea
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{green}❯%f '

# Sin separadores para efecto de bloque
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
```

## 🚀 Cómo Usar

### **Instalación Automática**
```bash
# Instalar todo el setup con tema rastafari
./setup.sh
# Seleccionar opción 2: Configure Zsh + Oh My Zsh

# O instalación completa
./setup.sh auto
```

### **Demo Interactivo**
```bash
# Desde el menú principal
./setup.sh
# Seleccionar opción R: Rastafari Theme Demo

# O directamente
./modules/rastafari-theme-demo.sh
```

### **Activación Manual**
```bash
# Recargar configuración
source ~/.p10k.zsh

# Reiniciar shell
exec zsh

# Verificar tema
p10k reload
```

## 📋 Verificación de Instalación

### **Checklist del Tema**
- ✅ Powerlevel10k instalado
- ✅ Archivo `.p10k.zsh` con configuración rastafari
- ✅ Funciones `prompt_system_cpu` y `prompt_system_memory`
- ✅ Zsh configurado como shell por defecto
- ✅ Colores rastafari activos

### **Comando de Verificación**
```bash
# Usar el script de demo para verificar
./modules/rastafari-theme-demo.sh
# Opción 2: Verificar instalación
```

## 🎨 Personalización Avanzada

### **Cambiar Umbrales de Color**
```bash
# Editar ~/.p10k.zsh
# Modificar las condiciones en las funciones:
if (( cpu_usage < 30 )); then    # Verde
elif (( cpu_usage < 70 )); then  # Amarillo
else                             # Rojo
```

### **Agregar Más Métricas**
```bash
# Ejemplo: Temperatura de CPU (si disponible)
function prompt_system_temp() {
    local temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    if [[ -n "$temp" ]]; then
        temp=$((temp / 1000))
        p10k segment -f 15 -b 1 -i '🌡️' -t "${temp}°C"
    fi
}
```

## 🌟 Beneficios del Tema

### **Para Desarrollo**
- 📊 **Monitoreo en tiempo real** de recursos del sistema
- 🎯 **Información visual clara** del estado del proyecto (Git)
- ⚡ **Respuesta rápida** a cambios en el sistema
- 🧭 **Navegación mejorada** con información de directorio clara

### **Para Experiencia de Usuario**
- 🌈 **Estilo único y llamativo** con colores rastafari
- 📱 **Optimizado para Termux** en dispositivos móviles
- 🔄 **Actualización dinámica** de información
- 👁️ **Fácil lectura** con contraste apropiado

## 🛠️ Troubleshooting

### **Tema no se muestra**
```bash
# Verificar instalación de Powerlevel10k
ls -la ~/.oh-my-zsh/custom/themes/powerlevel10k

# Verificar configuración
grep "RASTAFARI" ~/.p10k.zsh

# Recargar configuración
source ~/.zshrc && source ~/.p10k.zsh
```

### **Métricas no aparecen**
```bash
# Verificar /proc/stat y /proc/meminfo
ls -la /proc/stat /proc/meminfo

# Verificar funciones en .p10k.zsh
grep -A 10 "prompt_system_cpu" ~/.p10k.zsh
```

### **Colores incorrectos**
```bash
# Verificar soporte de colores del terminal
echo $TERM
tput colors

# Verificar configuración de Termux
cat ~/.termux/termux.properties
```

## 📞 Comandos Útiles

```bash
# Recargar tema
p10k reload

# Configurar interactivamente
p10k configure

# Ver métricas actuales
./modules/rastafari-theme-demo.sh  # Opción 3

# Reiniciar con tema
exec zsh

# Verificar instalación completa
./modules/rastafari-theme-demo.sh  # Opción 2
```

---

## 🎉 Resultado Final

El tema Rastafari proporciona una experiencia visual única con:

- 🌈 **Bloques coloridos** en estilo rastafari (rojo, amarillo, verde)
- 💻 **Métricas en tiempo real** de CPU y memoria
- 📍 **Información contextual** clara del proyecto y sistema
- ⚡ **Performance optimizada** para Termux
- 🎨 **Estilo diferenciado** que hace única tu terminal

¡Perfecto para desarrolladores que buscan una terminal funcional y con estilo! 🇯🇲