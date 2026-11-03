# Termux AI Control Panel - Web UI

Interfaz web moderna para el panel de control de Termux AI, construida con Vite, TailwindCSS y WebSockets.

## 🚀 Características

- **Monitoreo en Tiempo Real**: Estado del sistema actualizado automáticamente
- **Interfaz Responsive**: Funciona en dispositivos móviles y desktop
- **Dark Mode**: Tema oscuro optimizado para terminales
- **WebSockets**: Comunicación bidireccional con el backend
- **Acciones Remotas**: Control del sistema desde la interfaz web

## 🛠️ Tecnologías

- **Frontend**: Vite + Vanilla JavaScript + TailwindCSS
- **WebSockets**: Socket.IO Client
- **Build System**: Vite con Hot Module Replacement
- **CSS Framework**: TailwindCSS con componentes personalizados

## 📦 Instalación

```bash
# Desde el directorio raíz del proyecto
./start-panel.sh install

# O manualmente:
cd web-ui
npm install
```

## 🏃‍♂️ Desarrollo

```bash
# Iniciar servidor de desarrollo
./start-panel.sh dev

# O manualmente:
cd web-ui
npm run dev
```

La aplicación estará disponible en `http://localhost:3000`

## 🏗️ Build para Producción

```bash
# Build completo (frontend + backend)
./start-panel.sh build

# O solo frontend:
cd web-ui
npm run build
```

## 📱 Características de la UI

### Dashboard Principal

- **Estado del Sistema**: Node.js, Git, Zsh, Neovim, CLIs de IA (claude, opencode, codex, wrangler, agy), SSH
- **Uso del Disco**: Tamaños de directorios importantes
- **Proyectos Git**: Repositorios en `~/src` con estado de cambios
- **Logs en Tiempo Real**: Actividad del sistema y acciones

### Controles Disponibles

- 🔑 **Mostrar Llave SSH**: Visualiza la clave pública para GitHub
- 🌐 **Habilitar SSH**: Activa el servidor SSH permanente
- 🖥️ **Servidor HTTP**: Control del servidor en puerto 9999
- 🤖 **Estado CLIs IA**: Inventario de `claude`, `opencode`, `codex`, `wrangler` y `agy`
  (con ruta y versión; `agy` es instalación manual desde https://antigravity.google)

### Estado de Conexión

- **WebSocket**: Estado de conexión con el backend
- **Backend**: Estado del servidor FastAPI
- **HTTP Server**: Estado del servidor de archivos estáticos

## 🔧 Estructura del Proyecto

```text
web-ui/
├── index.html              # Página principal
├── package.json            # Dependencias npm
├── vite.config.js          # Configuración de Vite
├── tailwind.config.js      # Configuración de TailwindCSS
├── postcss.config.js       # Configuración de PostCSS
└── src/
    ├── main.js             # Aplicación principal
    └── style.css           # Estilos con TailwindCSS
```

## 🌐 Integración con Backend

La UI se comunica con el backend FastAPI a través de:

- **WebSocket**: `ws://localhost:8000/socket.io`
- **REST API**: `http://localhost:8000/api/`

### Eventos WebSocket

- `connect/disconnect`: Estado de conexión
- `system_status`: Estado de componentes del sistema
- `disk_usage`: Información de uso del disco
- `git_projects`: Lista de proyectos Git
- `ssh_key`: Llave SSH pública
- `log`: Mensajes de log en tiempo real

### Acciones Disponibles

```javascript
// Enviar acción al backend
socket.emit('action', {
  type: 'show_ssh_key',
  params: {}
});
```

## 🎨 Personalización

### Colores y Tema

Los colores se definen en `tailwind.config.js`:

```javascript
theme: {
  extend: {
    colors: {
      primary: { /* azul */ },
      dark: { /* grises oscuros */ }
    }
  }
}
```

### Componentes CSS

Clases personalizadas en `src/style.css`:

- `.card`: Tarjetas del dashboard
- `.btn-*`: Botones con variantes
- `.status-*`: Indicadores de estado

## 🚀 Despliegue

Para usar en producción:

1. **Build**: `./start-panel.sh build`
2. **Start**: `./start-panel.sh start`
3. **Acceso**: `http://localhost:8000`

El backend FastAPI sirve automáticamente los archivos estáticos del frontend.

## 🐛 Troubleshooting

### Problemas Comunes

1. **WebSocket no conecta**: Verificar que el backend esté corriendo en puerto 8000
2. **Dependencias faltantes**: Ejecutar `./start-panel.sh install`
3. **Puerto ocupado**: Cambiar puertos en `vite.config.js` y `backend/main.py`

### Logs de Debug

```bash
# Ver logs del frontend
npm run dev

# Ver logs del backend
cd backend && python main.py
```

## 📚 Referencias

- [Vite Documentation](https://vitejs.dev/)
- [TailwindCSS Documentation](https://tailwindcss.com/)
- [Socket.IO Client](https://socket.io/docs/v4/client-api/)
- [FastAPI WebSockets](https://fastapi.tiangolo.com/advanced/websockets/)
