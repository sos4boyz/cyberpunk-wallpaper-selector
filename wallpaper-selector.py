#!/usr/bin/env python3
"""
Cyberpunk Wallpaper Selector for bspwm
Futuristic glassmorphism interface with neon accents
"""

import tkinter as tk
from tkinter import font as tkfont
from PIL import Image, ImageTk, ImageFilter, ImageEnhance
import os
import subprocess
import sys
import fcntl
from pathlib import Path

# Single instance lock
LOCK_FILE = Path("/tmp/wallpaper-selector.lock")

def acquire_lock():
    """Ensure only one instance runs"""
    try:
        # Remove stale lock file if process doesn't exist
        if LOCK_FILE.exists():
            try:
                with open(LOCK_FILE, 'r') as f:
                    pid = int(f.read().strip())
                # Check if process is running
                os.kill(pid, 0)
                # Process exists, another instance is running
                print("Wallpaper selector already running!")
                sys.exit(0)
            except (ValueError, ProcessLookupError, OSError):
                # Stale lock file, remove it
                LOCK_FILE.unlink()

        # Create new lock file
        with open(LOCK_FILE, 'w') as f:
            f.write(str(os.getpid()))
        return True
    except Exception as e:
        print(f"Lock error: {e}")
        return False

def release_lock():
    """Release the lock file"""
    try:
        if LOCK_FILE.exists():
            LOCK_FILE.unlink()
    except:
        pass

# Acquire lock before running
if not acquire_lock():
    sys.exit(1)

class CyberWallpaperSelector:
    def __init__(self, root):
        self.root = root
        self.root.configure(bg='#050505')
        self.root.attributes('-fullscreen', True)

        # Colors - Cyberpunk theme
        self.bg_color = '#050505'
        self.neon_cyan = '#00f0ff'
        self.neon_pink = '#ff00ff'
        self.neon_purple = '#9d00ff'
        self.text_color = '#ffffff'
        self.dim_color = '#1a1a2e'

        # Performance tracking
        self._last_thumb_range = (-1, -1)

        # Key bindings
        self.root.bind('<Escape>', lambda e: self.quit())
        self.root.bind('<q>', lambda e: self.quit())
        self.root.bind('<Left>', lambda e: self.prev())
        self.root.bind('<Right>', lambda e: self.next())
        self.root.bind('<Return>', lambda e: self.apply())
        self.root.bind('<space>', lambda e: self.apply())

        # Screen dimensions
        self.sw = self.root.winfo_screenwidth()
        self.sh = self.root.winfo_screenheight()

        # Wallpaper setup
        self.wp_dir = Path.home() / "Wallpapers"
        self.wallpapers = self.get_wallpapers()
        self.current_idx = 0
        self.previews = {}
        self.previews_size = {}
        self.thumbs = {}

        if not self.wallpapers:
            print("No wallpapers found!")
            self.quit()
            return

        # Sizes - smaller thumbnails for performance
        self.main_h = int(self.sh * 0.55)
        self.main_w = int(self.main_h * 1.77)  # 16:9
        self.thumb_h = int(self.sh * 0.10)  # Smaller thumbnails
        self.thumb_w = int(self.thumb_h * 1.77)

        # Build UI first for instant response
        self.build_ui()

        # Load current image and visible thumbnails first
        self.load_current_and_visible()
        self.update_view()

        # Load remaining images in background
        self.root.after_idle(self.load_remaining_images)

        # Animation
        self.animate_entry()

    def get_wallpapers(self):
        exts = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'}
        if not self.wp_dir.exists():
            return []
        files = [f for f in self.wp_dir.iterdir()
                if f.suffix.lower() in exts and not f.name.startswith('.')]
        return sorted(files)

    def load_image(self, wp):
        """Load a single image with its thumbnail"""
        try:
            if wp in self.previews:
                return True

            img = Image.open(wp)
            if img.mode in ('RGBA', 'P'):
                img = img.convert('RGB')

            # Resize maintaining aspect for main preview
            orig_w, orig_h = img.size
            scale = min(self.main_w / orig_w, self.main_h / orig_h)
            new_w = int(orig_w * scale)
            new_h = int(orig_h * scale)

            img_resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
            self.previews[wp] = ImageTk.PhotoImage(img_resized)
            self.previews_size[wp] = (new_w, new_h)

            # Load thumbnail - smaller size for faster loading
            thumb = img.copy()
            thumb.thumbnail((self.thumb_w, self.thumb_h), Image.Resampling.LANCZOS)

            # Dimmed version for non-selected
            thumb_dim = thumb.copy()
            enhancer = ImageEnhance.Brightness(thumb_dim)
            thumb_dim = enhancer.enhance(0.4)

            self.thumbs[wp] = {
                'normal': ImageTk.PhotoImage(thumb),
                'dimmed': ImageTk.PhotoImage(thumb_dim)
            }
            return True
        except Exception as e:
            print(f"Error loading {wp}: {e}")
            return False

    def load_current_image(self):
        """Load only the current image for instant display"""
        if self.wallpapers:
            self.load_image(self.wallpapers[self.current_idx])

    def load_current_and_visible(self):
        """Load current image and visible thumbnails for instant response"""
        if not self.wallpapers:
            return

        # Current image
        self.load_image(self.wallpapers[self.current_idx])

        # Visible thumbnails
        visible = 5
        half = visible // 2
        start = max(0, self.current_idx - half)
        end = min(len(self.wallpapers), start + visible)

        for i in range(start, end):
            if i != self.current_idx:
                self.load_image(self.wallpapers[i])

    def load_remaining_images(self):
        """Load remaining images using idle callbacks for smoothness"""
        if not self.wallpapers:
            return

        # Priority: visible thumbnails first
        visible = 5
        half = visible // 2
        start = max(0, self.current_idx - half)
        end = min(len(self.wallpapers), start + visible)

        # Load visible thumbnails first
        visible_loaded = False
        for i in range(start, end):
            if i != self.current_idx and self.wallpapers[i] not in self.previews:
                self.load_image(self.wallpapers[i])
                visible_loaded = True

        if visible_loaded:
            self.root.after_idle(self.update_thumbnails)

        # Schedule rest for later
        self.root.after(100, self.load_hidden_images)

    def load_hidden_images(self):
        """Load non-visible images in background"""
        visible = 5
        half = visible // 2
        start = max(0, self.current_idx - half)
        end = min(len(self.wallpapers), start + visible)

        visible_indices = set(range(start, end))

        # Load one hidden image at a time
        for i, wp in enumerate(self.wallpapers):
            if i != self.current_idx and i not in visible_indices and wp not in self.previews:
                self.load_image(wp)
                # Schedule next one
                self.root.after(50, self.load_hidden_images)
                return

    def load_all_images(self):
        """Legacy: load all images synchronously (not used)"""
        for wp in self.wallpapers:
            self.load_image(wp)

    def build_ui(self):
        """Create futuristic UI"""
        self.root.configure(bg=self.bg_color)

        # Custom fonts
        self.font_title = tkfont.Font(family="Helvetica Neue", size=24, weight="bold")
        self.font_sub = tkfont.Font(family="Helvetica Neue", size=12)
        self.font_info = tkfont.Font(family="Consolas", size=11)
        self.font_counter = tkfont.Font(family="Consolas", size=14, weight="bold")

        # Main container
        main = tk.Frame(self.root, bg=self.bg_color)
        main.place(relx=0.5, rely=0.5, anchor='center')

        # Decorative top line
        top_line = tk.Canvas(self.root, height=2, bg=self.bg_color, highlightthickness=0)
        top_line.place(x=0, y=20, relwidth=1)
        top_line.create_line(0, 1, self.sw, 1, fill=self.neon_cyan, width=2)

        # Title with glow effect
        title_frame = tk.Frame(self.root, bg=self.bg_color)
        title_frame.place(relx=0.5, y=50, anchor='n')

        self.title = tk.Label(
            title_frame,
            text="◢ WALLPAPER SELECTOR ◣",
            font=self.font_title,
            bg=self.bg_color,
            fg=self.neon_cyan
        )
        self.title.pack()

        # Subtitle
        self.subtitle = tk.Label(
            title_frame,
            text="「 Select your environment 」",
            font=self.font_sub,
            bg=self.bg_color,
            fg=self.neon_purple
        )
        self.subtitle.pack()

        # Main display area - Container with glass effect
        self.display_frame = tk.Frame(
            main,
            bg='#0a0a0f',
            padx=20,
            pady=20
        )
        self.display_frame.pack(pady=20)

        # Corner decorations
        self.add_corners(self.display_frame)

        # Main image label
        self.main_label = tk.Label(
            self.display_frame,
            bg='#000000',
            cursor='hand2'
        )
        self.main_label.pack()
        self.main_label.bind('<Button-1>', lambda e: self.apply())

        # Info panel
        info_frame = tk.Frame(main, bg=self.bg_color)
        info_frame.pack(pady=15)

        self.filename_lbl = tk.Label(
            info_frame,
            text="",
            font=self.font_info,
            bg=self.bg_color,
            fg=self.text_color
        )
        self.filename_lbl.pack()

        self.path_lbl = tk.Label(
            info_frame,
            text="",
            font=('Consolas', 9),
            bg=self.bg_color,
            fg='#555555'
        )
        self.path_lbl.pack(pady=(5, 0))

        # Counter with style
        self.counter_lbl = tk.Label(
            info_frame,
            text="",
            font=self.font_counter,
            bg=self.bg_color,
            fg=self.neon_cyan
        )
        self.counter_lbl.pack(pady=10)

        # Thumbnail strip
        self.thumb_frame = tk.Frame(main, bg=self.bg_color)
        self.thumb_frame.pack(pady=20)

        self.thumb_labels = []
        self.thumb_widgets = []  # Cache widget references
        self.create_thumbnail_widgets()

        # Navigation buttons
        nav_frame = tk.Frame(main, bg=self.bg_color)
        nav_frame.pack(pady=10)

        # Left arrow
        self.btn_prev = self.create_neon_button(nav_frame, '◀ PREV', self.prev, self.neon_purple)
        self.btn_prev.pack(side=tk.LEFT, padx=20)

        # Apply button (prominent)
        self.btn_apply = self.create_neon_button(nav_frame, '▶ APPLY THEME ◀', self.apply, self.neon_cyan, large=True)
        self.btn_apply.pack(side=tk.LEFT, padx=30)

        # Right arrow
        self.btn_next = self.create_neon_button(nav_frame, 'NEXT ▶', self.next, self.neon_purple)
        self.btn_next.pack(side=tk.LEFT, padx=20)

        # Bottom instructions
        inst = tk.Label(
            self.root,
            text="[←] PREVIOUS  [→] NEXT  [ENTER] APPLY  [ESC] EXIT",
            font=('Consolas', 10),
            bg=self.bg_color,
            fg='#333333'
        )
        inst.place(relx=0.5, rely=0.95, anchor='center')

        # Bottom neon line
        bot_line = tk.Canvas(self.root, height=2, bg=self.bg_color, highlightthickness=0)
        bot_line.place(x=0, y=self.sh-20, relwidth=1)
        bot_line.create_line(0, 1, self.sw, 1, fill=self.neon_pink, width=2)

    def add_corners(self, frame):
        """Add cyberpunk corner decorations"""
        size = 15
        color = self.neon_cyan

        # We'll draw corners on a canvas behind the image
        w = self.main_w + 40
        h = self.main_h + 40

        self.corner_canvas = tk.Canvas(
            frame,
            width=w,
            height=h,
            bg=self.bg_color,
            highlightthickness=0
        )
        self.corner_canvas.place(x=0, y=0)

        # Draw corner lines
        # Top-left
        self.corner_canvas.create_line(0, size, 0, 0, size, 0, fill=color, width=3)
        # Top-right
        self.corner_canvas.create_line(w-size, 0, w, 0, w, size, fill=color, width=3)
        # Bottom-left
        self.corner_canvas.create_line(0, h-size, 0, h, size, h, fill=color, width=3)
        # Bottom-right
        self.corner_canvas.create_line(w-size, h, w, h, w, h-size, fill=color, width=3)

    def create_neon_button(self, parent, text, command, color, large=False):
        """Create neon-style button"""
        padding = 15 if large else 10
        font = ('Helvetica Neue', 14, 'bold') if large else ('Helvetica Neue', 11)

        frame = tk.Frame(parent, bg=color, padx=2, pady=2)

        btn = tk.Label(
            frame,
            text=text,
            font=font,
            bg='#0a0a0f',
            fg=color,
            padx=padding * 2,
            pady=padding,
            cursor='hand2'
        )
        btn.pack()

        def on_enter(e):
            btn.config(bg=color, fg='#000000')
        def on_leave(e):
            btn.config(bg='#0a0a0f', fg=color)

        btn.bind('<Enter>', on_enter)
        btn.bind('<Leave>', on_leave)
        btn.bind('<Button-1>', lambda e: command())

        return frame

    def update_view(self):
        """Update main display - optimized for smoothness"""
        if not self.wallpapers:
            return

        current = self.wallpapers[self.current_idx]

        # Load image if not cached (non-blocking)
        if current not in self.previews:
            self.load_image(current)

        # Update main image
        if current in self.previews:
            self.main_label.config(image=self.previews[current])
            self.main_label.image = self.previews[current]
            w, h = self.previews_size[current]
            self.main_label.config(width=w, height=h)

        # Update text
        self.filename_lbl.config(text=f"▸ {current.name}", fg=self.text_color)
        self.path_lbl.config(text=str(current.parent))
        self.counter_lbl.config(
            text=f"[{self.current_idx + 1:02d} / {len(self.wallpapers):02d}]"
        )

        # Update thumbnails immediately for responsiveness
        self.update_thumbnails()

    def create_thumbnail_widgets(self):
        """Create thumbnail widget placeholders once"""
        visible = 5

        for i in range(visible):
            thumb_container = tk.Frame(self.thumb_frame, bg=self.bg_color)
            thumb_container.pack(side=tk.LEFT, padx=5)

            border = tk.Frame(thumb_container, bg='#333333', padx=0, pady=0)
            border.pack()

            lbl = tk.Label(
                border,
                text="",
                font=('Consolas', 10),
                bg='#1a1a2e',
                fg='#666666',
                width=8,
                height=4,
                cursor='hand2'
            )
            lbl.pack()

            self.thumb_widgets.append({
                'container': thumb_container,
                'border': border,
                'label': lbl,
                'index': -1
            })

            lbl.bind('<Button-1>', lambda e, idx=i: self.select_from_widget(idx))

    def select_from_widget(self, widget_idx):
        """Select wallpaper from widget index"""
        if 0 <= widget_idx < len(self.thumb_widgets):
            actual_idx = self.thumb_widgets[widget_idx]['index']
            if actual_idx >= 0:
                self.select(actual_idx)

    def update_thumbnails(self):
        """Update thumbnail strip - optimized"""
        if not self.thumb_widgets or not self.wallpapers:
            return

        visible = 5
        half = visible // 2
        total = len(self.wallpapers)

        start = max(0, self.current_idx - half)
        end = min(total, start + visible)

        if end - start < visible:
            start = max(0, end - visible)

        # Update widgets
        for i, widget in enumerate(self.thumb_widgets):
            idx = start + i
            if idx >= total:
                widget['container'].pack_forget()
                continue

            wp = self.wallpapers[idx]
            is_selected = (idx == self.current_idx)
            widget['index'] = idx

            # Update image if loaded
            if wp in self.thumbs:
                img = self.thumbs[wp]['normal'] if is_selected else self.thumbs[wp]['dimmed']
                if widget['label'].cget('image') != str(img):
                    widget['label'].config(image=img, text="", width=0, height=0)
                    widget['label'].image = img
            else:
                if widget['label'].cget('text') != str(idx + 1):
                    widget['label'].config(image="", text=str(idx + 1), width=8, height=4)
                    widget['label'].image = None

            # Update border color
            border_color = self.neon_cyan if is_selected else '#333333'
            border_pad = 2 if is_selected else 0
            if widget['border'].cget('bg') != border_color:
                widget['border'].config(bg=border_color, padx=border_pad, pady=border_pad)
                widget['label'].config(fg=self.neon_cyan if is_selected else '#666666')

            widget['container'].pack(side=tk.LEFT, padx=5)

    def select(self, idx):
        """Select wallpaper by index"""
        if idx != self.current_idx and 0 <= idx < len(self.wallpapers):
            self.current_idx = idx
            self.update_view()

    def prev(self):
        if self.current_idx > 0:
            self.current_idx -= 1
            self.update_view()

    def next(self):
        if self.current_idx < len(self.wallpapers) - 1:
            self.current_idx += 1
            self.update_view()

    def apply(self):
        """Apply theme"""
        if not self.wallpapers:
            return

        wp = self.wallpapers[self.current_idx]

        # Visual feedback
        self.btn_apply.winfo_children()[0].config(
            text='◈ APPLYING... ◈',
            bg=self.neon_cyan,
            fg='#000000'
        )
        self.root.update()

        try:
            subprocess.run(['themes', str(wp)], check=True, capture_output=True)
            self.filename_lbl.config(
                text=f"✓ {wp.name}",
                fg=self.neon_cyan
            )
        except Exception as e:
            self.filename_lbl.config(
                text=f"✗ Error: {e}",
                fg=self.neon_pink
            )

        # Reset button
        self.root.after(1500, lambda: self.btn_apply.winfo_children()[0].config(
            text='▶ APPLY THEME ◀',
            bg='#0a0a0f',
            fg=self.neon_cyan
        ))
        self.root.after(1500, lambda: self.filename_lbl.config(fg=self.text_color))

    def animate_entry(self):
        """Entry animation - quick fade"""
        self.root.attributes('-alpha', 0.0)
        self.root.after(10, lambda: self.root.attributes('-alpha', 1.0))

    def quit(self):
        release_lock()
        self.root.quit()
        self.root.destroy()


if __name__ == '__main__':
    try:
        root = tk.Tk()

        # Reduce flickering
        root.tk.call('tk', 'scaling', 1.0)
        root.option_add('*DoubleBuffered', '1')

        app = CyberWallpaperSelector(root)
        root.mainloop()
    except Exception as e:
        print(f"Error: {e}")
        release_lock()
        sys.exit(1)
    finally:
        release_lock()
