# 🎨 Cyberpunk Wallpaper Selector

Un selector de wallpapers futurista con interfaz cyberpunk/glassmorphism para entornos Linux con bspwm. Incluye integración con pywal para sincronizar colores automáticamente con polybar y rofi.

![Python](https://img.shields.io/badge/Python-3.6+-blue.svg)
![Tkinter](https://img.shields.io/badge/Tkinter-8.6+-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Características

- 🖼️ **Interfaz futurista** - Diseño cyberpunk con efectos glassmorphism y neon
- 🎨 **Integración con pywal** - Extrae colores automáticamente del wallpaper seleccionado
- ⚡ **Rendimiento optimizado** - Carga lazy de imágenes para respuesta instantánea
- ⌨️ **Atajos de teclado** - Navegación rápida con flechas y teclas
- 🖥️ **Fullscreen** - Interfaz inmersiva de pantalla completa
- 🔒 **Single instance** - Evita múltiples ventanas simultáneas

## 📋 Requisitos

### Dependencias del Sistema

```bash
# Debian/Ubuntu/Kali
sudo apt update
sudo apt install python3 python3-pip python3-tk python3-pil python3-pil.imagetk feh

# Arch Linux
sudo pacman -S python python-pillow tk feh

# Fedora
sudo dnf install python3 python3-pillow python3-tkinter feh
```

### Dependencias Python

```bash
pip3 install Pillow pywal
```

O instálalas desde el archivo requirements:

```bash
pip3 install -r requirements.txt
```

### Opcionales (para tema completo)

- **bspwm** - Window manager (recomendado)
- **polybar** - Barra de estado (para cambio de colores)
- **rofi** - Launcher de aplicaciones (para cambio de colores)

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/tuusuario/cyberpunk-wallpaper-selector.git
cd cyberpunk-wallpaper-selector
```

### 2. Instalar dependencias

```bash
pip3 install -r requirements.txt
```

### 3. Configurar el script de temas (opcional)

Si usas polybar y quieres que los colores cambien automáticamente:

```bash
# Copiar el script themes a tu PATH
chmod +x themes
sudo cp themes /usr/local/bin/

# Crear directorios de configuración si no existen
mkdir -p ~/.config/polybar/shapes/scripts/rofi
mkdir -p ~/.cache/wal
```

### 4. Crear directorio de wallpapers

```bash
mkdir -p ~/Wallpapers
```

Copia tus wallpapers a esta carpeta (soporta: `.jpg`, `.jpeg`, `.png`, `.webp`, `.bmp`)

## 🎮 Uso

### Ejecutar el selector

```bash
python3 wallpaper-selector.py
```

### Atajos de teclado

| Tecla | Acción |
|-------|--------|
| `←` (Flecha izquierda) | Wallpaper anterior |
| `→` (Flecha derecha) | Wallpaper siguiente |
| `Enter` / `Space` | Aplicar tema |
| `Esc` / `Q` | Salir |

### Uso con atajo de teclado en bspwm

Agrega a tu `~/.config/sxhkd/sxhkdrc`:

```bash
# Launch wallpaper selector
super + alt + w
    python3 ~/ruta/al/wallpaper-selector.py
```

## 🏗️ Estructura del Proyecto

```
cyberpunk-wallpaper-selector/
├── wallpaper-selector.py    # Aplicación principal
├── themes                   # Script para aplicar colores con pywal
├── requirements.txt         # Dependencias Python
├── wallpaper-selector.desktop  # Entrada de escritorio
└── README.md               # Este archivo
```

## 📝 Configuración

### Personalizar colores

Edita las variables de color en `wallpaper-selector.py`:

```python
self.bg_color = '#050505'      # Fondo
self.neon_cyan = '#00f0ff'     # Cyan neón
self.neon_pink = '#ff00ff'     # Rosa neón
self.neon_purple = '#9d00ff'   # Púrpura neón
```

### Ajustar tamaño de thumbnails

```python
self.thumb_h = int(self.sh * 0.10)  # 10% de la altura de pantalla
```

## 🔧 Solución de Problemas

### Error: `No module named 'tkinter'`

```bash
# Debian/Ubuntu/Kali
sudo apt install python3-tk

# Arch
sudo pacman -S tk
```

### Error: `No module named 'PIL'`

```bash
pip3 install Pillow
```

### Error: `wal: command not found`

```bash
pip3 install pywal
```

### El selector no abre

Verifica que tienes imágenes en `~/Wallpapers`:

```bash
ls ~/Wallpapers
```

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agrega nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo MIT License - ver el archivo [LICENSE](LICENSE) para detalles.

## 🙏 Créditos

- Diseño cyberpunk inspirado en interfaces futuristas
- Integración con [pywal](https://github.com/dylanaraps/pywal) para extracción de colores
- Desarrollado para entornos bspwm/polybar

---

<p align="center">Desarrollado con 💜 y código</p>
