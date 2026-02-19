# 📦 System Resources & Dependencies

This document provides a comprehensive list of all packages, fonts, and utilities required to replicate this Hyprland configuration.

## 🖥️ Core Desktop Environment

| Component | Package | Description |
|-----------|---------|-------------|
| **Compositor** | `hyprland` | The dynamic tiling Wayland compositor. |
| **Status Bar** | `waybar` | Highly customizable bar for Hyprland. |
| **Launcher** | `rofi` | Application launcher and window switcher (Wayland fork). |
| **Terminal** | `alacritty` | GPU-accelerated terminal emulator (default config). |
| **Notifications** | `mako` | Lightweight notification daemon for Wayland. |
| **Wallpaper** | `hyprpaper` | Fast wallpaper utility. |
| **Lock Screen** | `hyprlock` | (Optional) Screen locking utility. |
| **Idle Daemon** | `hypridle` | (Optional) Idle management daemon. |

## 🛠️ Essential Utilities

| Category | Package | Description |
|----------|---------|-------------|
| **Screenshot** | `slurp` | Select region for screenshots. |
| **Screenshot** | `grim` | Grab images from Wayland compositor. |
| **Clipboard** | `wl-clipboard` | CLI copy/paste tools (`wl-copy`, `wl-paste`). |
| **Brightness** | `brightnessctl` | Hardware brightness control. |
| **Audio** | `pamixer` | PulseAudio command-line mixer. |
| **Audio** | `pavucontrol` | GUI volume control. |
| **Network** | `network-manager-applet` | System tray icon for NetworkManager (`nm-applet`). |
| **Bluetooth** | `blueman` | GTK+ Bluetooth Manager. |
| **Files** | `thunar` | (Optional) Graphical file manager. |

## 🎨 Fonts & Appearance

These fonts are **critical** for icons in the status bar and launcher to render correctly.

- **`ttf-jetbrains-mono-nerd`**: Primary monospaced font with icons.
- **`ttf-font-awesome`**: Icon font for specific glyphs.
- **`noto-fonts`**: Standard font family for broad language support.
- **`noto-fonts-emoji`**: Color emoji support.
- **`hyprshade`**: (AUR) Screen shader, used for the **Night Mode** script.

## 🐍 Script Dependencies

These tools are used internally by the scripts in `~/.config/hypr/scripts` and `~/.config/waybar/scripts`.

- **`jq`**: Lightweight command-line JSON processor.
- **`bc`**: Arbitrary precision calculator language.
- **`socat`**: Multipurpose relay (socket piping).
- **`python`**: Required for some advanced scripts.
- **`playerctl`**: Utility to control media players (Spotify, VLC, Firefox, etc.).

## 📦 One-Liner Installation

You can install all official packages with this command:

```bash
sudo pacman -S hyprland waybar rofi alacritty mako \
    pipewire wireplumber pamixer pavucontrol \
    brightnessctl network-manager-applet blueman \
    slurp grim wl-clipboard \
    jq bc socat playerctl python \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
```

And AUR packages with your helper (e.g., `yay`):

```bash
yay -S hyprpaper hyprshade ttf-font-awesome
```
