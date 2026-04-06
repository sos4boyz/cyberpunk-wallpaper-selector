#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  ⛓️ Gothic Wallpaper Selector - Instalador Oficial ⛓️                    ║
# ║  🖤 Instalación automática con accesos directos en tinieblas ⚰️          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

# ⛓️ Colores oscuros
BLOOD='\033[0;31m'
VOID='\033[0;35m'
SILVER='\033[0;37m'
DARK='\033[1;30m'
NC='\033[0m' # No Color

# 🦇 Banner gótico
echo ""
echo -e "${DARK}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${DARK}║${VOID}     ██╗  ██╗██╗   ██╗██╗  ██╗███████╗███████╗██╗          ${DARK}║${NC}"
echo -e "${DARK}║${VOID}     ██║ ██╔╝██║   ██║██║  ██║██╔════╝██╔════╝██║          ${DARK}║${NC}"
echo -e "${DARK}║${VOID}     █████╔╝ ██║   ██║███████║█████╗  ███████╗██║          ${DARK}║${NC}"
echo -e "${DARK}║${VOID}     ██╔═██╗ ██║   ██║██╔══██║██╔══╝  ╚════██║██║          ${DARK}║${NC}"
echo -e "${DARK}║${VOID}     ██║  ██╗╚██████╔╝██║  ██║██║     ███████║███████╗     ${DARK}║${NC}"
echo -e "${DARK}║${VOID}     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝     ${DARK}║${NC}"
echo -e "${DARK}║                                                                ║${NC}"
echo -e "${DARK}║${BLOOD}         ⛓️ GOTHIC WALLPAPER SELECTOR ⛓️                      ${DARK}║${NC}"
echo -e "${DARK}║${VOID}              🖤 by sos4boyz 🖤                                 ${DARK}║${NC}"
echo -e "${DARK}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 📍 Detectar distribución
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${BLOOD}❌ No se pudo detectar la distribución${NC}"
    exit 1
fi

echo -e "📦 ${SILVER}Distribución detectada:${NC} $OS"
echo ""

# 🔧 Instalar dependencias del sistema
echo -e "${VOID}🔧 Instalando dependencias del sistema...${NC}"

case $OS in
    debian|ubuntu|kali|pop|elementary|linuxmint)
        echo -e "${SILVER}📦 Usando apt...${NC}"
        sudo apt update
        sudo apt install -y python3 python3-pip python3-tk python3-pil python3-pil.imagetk feh git
        ;;
    arch|manjaro|endeavouros|garuda)
        echo -e "${SILVER}📦 Usando pacman...${NC}"
        sudo pacman -Sy --noconfirm python python-pillow tk feh git
        ;;
    fedora|centos|rhel)
        echo -e "${SILVER}📦 Usando dnf...${NC}"
        sudo dnf install -y python3 python3-pillow python3-tkinter feh git
        ;;
    *)
        echo -e "${SILVER}⚠️ Distribución no soportada oficialmente. Intentando con pip...${NC}"
        ;;
esac

# 🐍 Instalar dependencias Python
echo ""
echo -e "${VOID}🐍 Instalando dependencias Python...${NC}"
pip3 install --user Pillow pywal

# 📁 Crear directorio de wallpapers
echo ""
echo -e "${VOID}📁 Preparando directorio de wallpapers...${NC}"
mkdir -p ~/Wallpapers

# 🖼️ Copiar wallpapers de ejemplo
if [ -d "Wallpapers" ] && [ "$(ls -A Wallpapers 2>/dev/null)" ]; then
    echo -e "${SILVER}🖼️  Copiando wallpapers de ejemplo...${NC}"
    cp Wallpapers/* ~/Wallpapers/ 2>/dev/null || true
    echo -e "${BLOOD}✅ Wallpapers copiados a ~/Wallpapers/${NC}"
fi

# 📜 Copiar el script themes al PATH (opcional)
echo ""
echo -e "${VOID}🔧 Configurando script de temas...${NC}"
if [ -f "themes" ]; then
    chmod +x themes
    sudo cp themes /usr/local/bin/
    echo -e "${BLOOD}✅ Script 'themes' instalado en /usr/local/bin/${NC}"
fi

# 🚀 Hacer ejecutable el selector
echo ""
echo -e "${VOID}⚰️ Configurando ejecutables...${NC}"
chmod +x wallpaper-selector.py

# 🖥️ Crear acceso directo global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crear symlink en /usr/local/bin (requiere sudo)
echo -e "${SILVER}🔗 Creando acceso directo global 'gothic-wallpaper'...${NC}"
echo "#!/bin/bash" | sudo tee /usr/local/bin/gothic-wallpaper > /dev/null
echo "python3 $SCRIPT_DIR/wallpaper-selector.py" | sudo tee -a /usr/local/bin/gothic-wallpaper > /dev/null
sudo chmod +x /usr/local/bin/gothic-wallpaper
echo -e "${BLOOD}✅ Ahora puedes ejecutar: gothic-wallpaper${NC}"

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

    echo -e "${BLOOD}✅ Entrada de escritorio creada${NC}"
fi

# ⌨️ Opcional: Crear atajo de teclado para sxhkd (bspwm)
echo ""
read -p "¿Usas bspwm? ¿Agregar atajo Super+Alt+W? [y/N]: " add_shortcut
if [[ $add_shortcut =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/sxhkd" ]; then
        echo "" >> ~/.config/sxhkd/sxhkdrc
        echo "# ⛓️ Gothic Wallpaper Selector" >> ~/.config/sxhkd/sxhkdrc
        echo "super + alt + w" >> ~/.config/sxhkd/sxhkdrc
        echo "    python3 $SCRIPT_DIR/wallpaper-selector.py" >> ~/.config/sxhkd/sxhkdrc
        echo -e "${BLOOD}✅ Atajo de teclado agregado a sxhkdrc${NC}"
        echo -e "${SILVER}⚠️  Recuerda reiniciar sxhkd:${NC} killall sxhkd && sxhkd &"
    else
        echo -e "${SILVER}⚠️ No se encontró configuración de sxhkd${NC}"
    fi
fi

# 📂 Opcional: Crear alias en .bashrc
echo ""
read -p "¿Crear alias 'goth' en .bashrc? [Y/n]: " create_alias
if [[ $create_alias =~ ^[Yy]$ ]] || [[ -z $create_alias ]]; then
    echo "" >> ~/.bashrc
    echo "# ⛓️ Gothic Wallpaper Selector Alias" >> ~/.bashrc
    echo "alias goth='python3 $SCRIPT_DIR/wallpaper-selector.py'" >> ~/.bashrc
    echo -e "${BLOOD}✅ Alias 'goth' creado${NC}"
    echo -e "${SILVER}⚠️  Recarga tu .bashrc:${NC} source ~/.bashrc"
fi

# 📂 Opcional: Crear alias en .zshrc
if [ -f "$HOME/.zshrc" ]; then
    read -p "¿Crear alias 'goth' en .zshrc? [Y/n]: " create_zsh_alias
    if [[ $create_zsh_alias =~ ^[Yy]$ ]] || [[ -z $create_zsh_alias ]]; then
        echo "" >> ~/.zshrc
        echo "# ⛓️ Gothic Wallpaper Selector Alias" >> ~/.zshrc
        echo "alias goth='python3 $SCRIPT_DIR/wallpaper-selector.py'" >> ~/.zshrc
        echo -e "${BLOOD}✅ Alias 'goth' creado en .zshrc${NC}"
    fi
fi

# 🎉 Fin de instalación
echo ""
echo -e "${DARK}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${DARK}║${BLOOD}                    ✅ INSTALACIÓN COMPLETADA ✅                 ${DARK}║${NC}"
echo -e "${DARK}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${VOID}🗝️  Resumen de accesos creados:${NC}"
echo -e "  ${DARK}•${NC} Comando global: ${BLOOD}gothic-wallpaper${NC}"
echo -e "  ${DARK}•${NC} Ejecutar directo: ${BLOOD}python3 $SCRIPT_DIR/wallpaper-selector.py${NC}"
echo -e "  ${DARK}•${NC} Alias (bash/zsh): ${BLOOD}goth${NC} (después de recargar shell)"
echo ""
echo -e "${VOID}📁 Ubicaciones:${NC}"
echo -e "  ${DARK}•${NC} Aplicación: ${BLOOD}$SCRIPT_DIR/${NC}"
echo -e "  ${DARK}•${NC} Wallpapers: ${BLOOD}~/Wallpapers/${NC}"
echo ""
echo -e "${VOID}⌨️  Atajos de teclado:${NC}"
echo -e "  ${DARK}•${NC} ← →         : Navegar"
echo -e "  ${DARK}•${NC} Enter/Space  : Aplicar"
echo -e "  ${DARK}•${NC} Esc/Q        : Salir"
if [[ $add_shortcut =~ ^[Yy]$ ]]; then
    echo -e "  ${DARK}•${NC} Super+Alt+W  : Abrir selector (bspwm)"
fi
echo ""
echo -e "${DARK}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLOOD}  ⚰️ ¡Listo para usar! Ejecuta 'gothic-wallpaper' para empezar${NC}"
echo -e "${DARK}══════════════════════════════════════════════════════════════════${NC}"
echo ""
