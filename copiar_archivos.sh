#!/bin/bash

# Script para copiar archivos del repo al proyecto Xcode
# Uso: ./copiar_archivos.sh /ruta/a/tu/proyecto/xcode

SOURCE_DIR="$(pwd)"
TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
    echo "Uso: $0 /ruta/a/tu/proyecto/xcode"
    exit 1
fi

echo "📁 Copiando archivos desde: $SOURCE_DIR"
echo "📁 Hacia: $TARGET_DIR"

# Crear carpetas si no existen
mkdir -p "$TARGET_DIR/App"
mkdir -p "$TARGET_DIR/Models" 
mkdir -p "$TARGET_DIR/Views"
mkdir -p "$TARGET_DIR/ViewModels"
mkdir -p "$TARGET_DIR/Services"
mkdir -p "$TARGET_DIR/Utilities"

# Copiar archivos App
echo "📋 Copiando archivos App..."
cp "$SOURCE_DIR/Sources/App/"*.swift "$TARGET_DIR/App/"

# Copiar Models
echo "📋 Copiando Models..."
cp "$SOURCE_DIR/Sources/Models/"*.swift "$TARGET_DIR/Models/"

# Copiar Views
echo "📋 Copiando Views..."
cp "$SOURCE_DIR/Sources/Views/"*.swift "$TARGET_DIR/Views/"

# Copiar ViewModels
echo "📋 Copiando ViewModels..."
cp "$SOURCE_DIR/Sources/ViewModels/"*.swift "$TARGET_DIR/ViewModels/"

# Copiar Services
echo "📋 Copiando Services..."
cp "$SOURCE_DIR/Sources/Services/"*.swift "$TARGET_DIR/Services/"

# Copiar Utilities
echo "📋 Copiando Utilities..."
cp "$SOURCE_DIR/Sources/Utilities/"*.swift "$TARGET_DIR/Utilities/"

echo "✅ Archivos copiados exitosamente!"
echo "🎮 Ahora arrastra las carpetas a Xcode y compila!"