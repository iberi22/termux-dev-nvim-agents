#!/bin/bash
#
# Lee la captura de pantalla más reciente y la devuelve en base64.

# Verificar si el almacenamiento está configurado
if [ ! -d "$HOME/storage" ]; then
    echo "Error: El almacenamiento de Termux no está configurado."
    echo "Por favor, ejecuta 'termux-setup-storage' y concede los permisos."
    exit 1
fi

# Posibles directorios de capturas de pantalla
SCREENSHOT_DIRS=(
    "$HOME/storage/pictures/Screenshots"
    "$HOME/storage/dcim/Screenshots"
)

LATEST_SCREENSHOT=""

# Encontrar la captura más reciente
for dir in "${SCREENSHOT_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        # Busca el archivo más reciente en el directorio actual
        current_latest=$(ls -t "$dir" | head -n 1)
        if [ -n "$current_latest" ]; then
            # Compara con el más reciente encontrado hasta ahora
            if [ -z "$LATEST_SCREENSHOT" ] || [ "$dir/$current_latest" -nt "$LATEST_SCREENSHOT" ]; then
                LATEST_SCREENSHOT="$dir/$current_latest"
            fi
        fi
    fi
done

# Verificar si se encontró una captura de pantalla
if [ -z "$LATEST_SCREENSHOT" ]; then
    echo "Error: No se encontraron capturas de pantalla en los directorios esperados."
    exit 1
fi

# Devolver la imagen en base64
echo "Leyendo la captura de pantalla más reciente: $LATEST_SCREENSHOT"
base64 "$LATEST_SCREENSHOT"
