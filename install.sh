#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  ⚡ Cyberpunk Wallpaper Selector - Instalador Oficial ⚡                  ║
# ║  🎨 Instalación automática con accesos directos incluidos 🖥️              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

# 🎨 Colores
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 🎭 Banner
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${PURPLE}     ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ██╗              ${CYAN}║${NC}"
echo -e "${CYAN}║${PURPLE}     ██║ ██╔╝██║   ██║██╔══██╗██╔════╝██╔══██╗██║              ${CYAN}║${NC}"
echo -e "${CYAN}║${PURPLE}     █████╔╝ ██║   ██║██████╔╝█████╗  ██████╔╝██║              ${CYAN}║${NC}"
echo -e "${CYAN}║${PURPLE}     ██╔═██╗ ██║   ██║██╔══██╗██╔══╝  ██╔══██╗██║              ${CYAN}║${NC}"
echo -e "${CYAN}║${PURPLE}     ██║  ██╗╚██████╔╝██████╔╝███████╗██║  ██║███████╗          ${CYAN}║${NC}"
echo -e "${CYAN}║${PURPLE}     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝          ${CYAN}║${NC}"
echo -e "${CYAN}║                                                                ║${NC}"
echo -e "${CYAN}║${CYAN}         🎨 CYBERPUNK WALLPAPER SELECTOR 🎨                    ${CYAN}║${NC}"
echo -e "${CYAN}║${PURPLE}              ⚡ by sos4boyz ⚡                                  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 📍 Detectar distribución
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}❌ No se pudo detectar la distribución${NC}"
    exit 1
fi

echo -e "📦 ${YELLOW}Distribución detectada:${NC} $OS"
echo ""

# 🔧 Instalar dependencias del sistema
echo -e "${CYAN}🔧 Instalando dependencias del sistema...${NC}"

case $OS in
    debian|ubuntu|kali|pop|elementary|linuxmint)
        echo -e "${YELLOW}📦 Usando apt...${NC}"
        sudo apt update
        sudo apt install -y python3 python3-pip python3-tk python3-pil python3-pil.imagetk feh git
        ;;
    arch|manjaro|endeavouros|garuda)
        echo -e "${YELLOW}📦 Usando pacman...${NC}"
        sudo pacman -Sy --noconfirm python python-pillow tk feh git
        ;;
    fedora|centos|rhel)
        echo -e "${YELLOW}📦 Usando dnf...${NC}"
        sudo dnf install -y python3 python3-pillow python3-tkinter feh git
        ;;
    *)
        echo -e "${YELLOW}⚠️ Distribución no soportada oficialmente. Intentando con pip...${NC}"
        ;;
esac

# 🐍 Instalar dependencias Python
echo ""
echo -e "${CYAN}🐍 Instalando dependencias Python...${NC}"
pip3 install --user Pillow pywal

# 📁 Crear directorio de wallpapers
echo ""
echo -e "${CYAN}📁 Preparando directorio de wallpapers...${NC}"
mkdir -p ~/Wallpapers

# 🖼️ Copiar wallpapers de ejemplo
if [ -d "Wallpapers" ] && [ "$(ls -A Wallpapers 2>/dev/null)" ]; then
    echo -e "${YELLOW}🖼️  Copiando wallpapers de ejemplo...${NC}"
    cp Wallpapers/* ~/Wallpapers/ 2>/dev/null || true
    echo -e "${GREEN}✅ Wallpapers copiados a ~/Wallpapers/${NC}"
fi

# 📜 Copiar el script themes al PATH (opcional)
echo ""
echo -e "${CYAN}🔧 Configurando script de temas...${NC}"
if [ -f "themes" ]; then
    chmod +x themes
    sudo cp themes /usr/local/bin/
    echo -e "${GREEN}✅ Script 'themes' instalado en /usr/local/bin/${NC}"
fi

# 🚀 Hacer ejecutable el selector
echo ""
echo -e "${CYAN}⚡ Configurando ejecutables...${NC}"
chmod +x wallpaper-selector.py

# 🖥️ Crear acceso directo global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crear symlink en /usr/local/bin (requiere sudo)
echo -e "${YELLOW}🔗 Creando acceso directo global 'cyberpunk-wallpaper'...${NC}"
echo "#!/bin/bash" | sudo tee /usr/local/bin/cyberpunk-wallpaper > /dev/null
echo "python3 $SCRIPT_DIR/wallpaper-selector.py" | sudo tee -a /usr/local/bin/cyberpunk-wallpaper > /dev/null
sudo chmod +x /usr/local/bin/cyberpunk-wallpaper
echo -e "${GREEN}✅ Ahora puedes ejecutar: cyberpunk-wallpaper${NC}"

# 🖥️ Opcional: Instalar entrada de escritorio
echo ""
read -p "¿Crear entrada en el menú de aplicaciones? [Y/n]: " create_desktop
if [[ $create_desktop =~ ^[Yy]$ ]] || [[ -z $create_desktop ]]; then
    # Actualizar ruta en el archivo .desktop
    sed -i "s|/home/gzkdeath|$HOME|g" wallpaper-selector.desktop
    sed -i "s|Exec=python3.*|Exec=python3 $SCRIPT_DIR/wallpaper-selector.py|g" wallpaper-selector.desktop

    mkdir -p ~/.local/share/applications
    cp wallpaper-selector.desktop ~/.local/share/applications/

    # Actualizar base de datos de aplicaciones
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database ~/.local/share/applications/
    fi

    echo -e "${GREEN}✅ Entrada de escritorio creada${NC}"
fi

# ⌨️ Opcional: Crear atajo de teclado para sxhkd (bspwm)
echo ""
read -p "¿Usas bspwm? ¿Agregar atajo Super+Alt+W? [y/N]: " add_shortcut
if [[ $add_shortcut =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/sxhkd" ]; then
        echo "" >> ~/.config/sxhkd/sxhkdrc
        echo "# 🎨 Cyberpunk Wallpaper Selector" >> ~/.config/sxhkd/sxhkdrc
        echo "super + alt + w" >> ~/.config/sxhkd/sxhkdrc
        echo "    python3 $SCRIPT_DIR/wallpaper-selector.py" >> ~/.config/sxhkd/sxhkdrc
        echo -e "${GREEN}✅ Atajo de teclado agregado a sxhkdrc${NC}"
        echo -e "${YELLOW}⚠️  Recuerda reiniciar sxhkd:${NC} killall sxhkd && sxhkd &"
    else
        echo -e "${YELLOW}⚠️ No se encontró configuración de sxhkd${NC}"
    fi
fi

# 📂 Opcional: Crear alias en .bashrc
echo ""
read -p "¿Crear alias 'wall' en .bashrc? [Y/n]: " create_alias
if [[ $create_alias =~ ^[Yy]$ ]] || [[ -z $create_alias ]]; then
    echo "" >> ~/.bashrc
    echo "# 🎨 Cyberpunk Wallpaper Selector Alias" >> ~/.bashrc
    echo "alias wall='python3 $SCRIPT_DIR/wallpaper-selector.py'" >> ~/.bashrc
    echo -e "${GREEN}✅ Alias 'wall' creado${NC}"
    echo -e "${YELLOW}⚠️  Recarga tu .bashrc:${NC} source ~/.bashrc"
fi

# 📂 Opcional: Crear alias en .zshrc
if [ -f "$HOME/.zshrc" ]; then
    read -p "¿Crear alias 'wall' en .zshrc? [Y/n]: " create_zsh_alias
    if [[ $create_zsh_alias =~ ^[Yy]$ ]] || [[ -z $create_zsh_alias ]]; then
        echo "" >> ~/.zshrc
        echo "# 🎨 Cyberpunk Wallpaper Selector Alias" >> ~/.zshrc
        echo "alias wall='python3 $SCRIPT_DIR/wallpaper-selector.py'" >> ~/.zshrc
        echo -e "${GREEN}✅ Alias 'wall' creado en .zshrc${NC}"
    fi
fi

# 🎉 Fin de instalación
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${GREEN}                    ✅ INSTALACIÓN COMPLETADA ✅                 ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${PURPLE}📋 Resumen de accesos creados:${NC}"
echo -e "  ${CYAN}•${NC} Comando global: ${GREEN}cyberpunk-wallpaper${NC}"
echo -e "  ${CYAN}•${NC} Ejecutar directo: ${GREEN}python3 $SCRIPT_DIR/wallpaper-selector.py${NC}"
echo -e "  ${CYAN}•${NC} Alias (bash/zsh): ${GREEN}wall${NC} (después de recargar shell)"
echo ""
echo -e "${PURPLE}📁 Ubicaciones:${NC}"
echo -e "  ${CYAN}•${NC} Aplicación: ${GREEN}$SCRIPT_DIR/${NC}"
echo -e "  ${CYAN}•${NC} Wallpapers: ${GREEN}~/Wallpapers/${NC}"
echo ""
echo -e "${PURPLE}⌨️  Atajos de teclado:${NC}"
echo -e "  ${CYAN}•${NC} ← →         : Navegar"
echo -e "  ${CYAN}•${NC} Enter/Space  : Aplicar"
echo -e "  ${CYAN}•${NC} Esc/Q        : Salir"
if [[ $add_shortcut =~ ^[Yy]$ ]]; then
    echo -e "  ${CYAN}•${NC} Super+Alt+W  : Abrir selector (bspwm)"
fi
echo ""
echo -e "${CYAN}═════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  🚀 ¡Listo para usar! Ejecuta 'cyberpunk-wallpaper' para empezar${NC}"
echo -e "${CYAN}═════════════════════════════════════════════════════════════════${NC}"
echo ""
