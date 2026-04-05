#!/bin/bash

# Script de instalación para Cyberpunk Wallpaper Selector
# Compatible con Debian/Ubuntu/Kali y Arch Linux

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║     Cyberpunk Wallpaper Selector - Instalador            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Detectar distribución
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ No se pudo detectar la distribución"
    exit 1
fi

echo "📦 Detectado: $OS"
echo ""

# Instalar dependencias del sistema
echo "🔧 Instalando dependencias del sistema..."

case $OS in
    debian|ubuntu|kali|pop|elementary|linuxmint)
        sudo apt update
        sudo apt install -y python3 python3-pip python3-tk python3-pil python3-pil.imagetk feh
        ;;
    arch|manjaro|endeavouros|garuda)
        sudo pacman -Sy --noconfirm python python-pillow tk feh
        ;;
    fedora|centos|rhel)
        sudo dnf install -y python3 python3-pillow python3-tkinter feh
        ;;
    *)
        echo "⚠️ Distribución no soportada oficialmente. Intentando con pip..."
        ;;
esac

# Instalar dependencias Python
echo ""
echo "🐍 Instalando dependencias Python..."
pip3 install --user Pillow pywal

# Crear directorio de wallpapers
echo ""
echo "📁 Creando directorio de wallpapers..."
mkdir -p ~/Wallpapers

# Copiar el script themes al PATH (opcional)
echo ""
read -p "¿Instalar el script 'themes' para pywal? (recomendado para polybar) [Y/n]: " install_themes
if [[ $install_themes =~ ^[Yy]$ ]] || [[ -z $install_themes ]]; then
    chmod +x themes
    sudo cp themes /usr/local/bin/
    echo "✅ Script 'themes' instalado en /usr/local/bin/"
fi

# Hacer ejecutable el selector principal
chmod +x wallpaper-selector.py

# Opcional: Instalar entrada de escritorio
echo ""
read -p "¿Crear entrada en el menú de aplicaciones? [Y/n]: " create_desktop
if [[ $create_desktop =~ ^[Yy]$ ]] || [[ -z $create_desktop ]]; then
    # Actualizar ruta en el archivo .desktop
    sed -i "s|/home/gzkdeath|$HOME|g" wallpaper-selector.desktop

    mkdir -p ~/.local/share/applications
    cp wallpaper-selector.desktop ~/.local/share/applications/

    # Actualizar base de datos de aplicaciones
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database ~/.local/share/applications/
    fi

    echo "✅ Entrada de escritorio creada"
fi

# Opcional: Crear atajo de teclado para sxhkd (bspwm)
echo ""
read -p "¿Usas bspwm? ¿Agregar atajo Super+Alt+W? [y/N]: " add_shortcut
if [[ $add_shortcut =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/sxhkd" ]; then
        echo "" >> ~/.config/sxhkd/sxhkdrc
        echo "# Cyberpunk Wallpaper Selector" >> ~/.config/sxhkd/sxhkdrc
        echo "super + alt + w" >> ~/.config/sxhkd/sxhkdrc
        echo "    python3 $PWD/wallpaper-selector.py" >> ~/.config/sxhkd/sxhkdrc
        echo "✅ Atajo de teclado agregado a sxhkdrc"
        echo "   Recuerda reiniciar sxhkd: killall sxhkd; sxhkd &"
    else
        echo "⚠️ No se encontró configuración de sxhkd"
    fi
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Instalación completada!"
echo ""
echo "📋 Instrucciones de uso:"
echo "   1. Copia tus wallpapers a ~/Wallpapers/"
echo "   2. Ejecuta: python3 $PWD/wallpaper-selector.py"
echo ""
echo "⌨️  Atajos de teclado:"
echo "   ← → : Navegar entre wallpapers"
echo "   Enter/Space : Aplicar tema"
echo "   Esc/Q : Salir"
echo "════════════════════════════════════════════════════════════"
